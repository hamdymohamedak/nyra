#![allow(unused_imports)]
//! Binary operators and numeric promotion.
use std::collections::{BTreeSet, HashMap, HashSet};
use std::fmt::Write;

use ast::*;
use ownership::{
    arrow_has_captures, arrow_to_block, callee_returns_owned, collect_arrow_captures,
    collect_captures, DropPlan, EscapePlan, EscapeState,
};

use crate::ansi_color::color_spec_to_ansi;
use crate::runtime_map::RuntimeProfile;

use super::{
    Binding, ClosureMeta, Codegen, DropState, Env, EnvKind, ExprValue, FnPtrSig, LoopPhiContext,
    NestedFnCodegenScope, LOCAL_CHANNEL_CAP, LOCAL_CHANNEL_TYPE,
};
use super::util::{
    array_elem_from_ty, array_len_from_ty, assign_target_name, collect_assigned_in_block,
    escape_string, host_target_triple, is_string_builtin_method, llvm_arith_rhs, llvm_binop_operand,
    llvm_cmp_operand, llvm_ptr, llvm_ptr_reg, llvm_storage_ty, llvm_string_len,
    llvm_struct_size_bytes, llvm_type_ann_resolved, llvm_ty_to_ann, resolve_struct_field_name,
    struct_name_from_llvm_ty, struct_ptr_type, struct_value_type, is_struct_pointer_type,
};

impl Codegen {
    pub(super) fn promote_to_double(&mut self, val: &mut ExprValue) {
        if val.ty == "double" {
            return;
        }
        if val.ty == "float" {
            let conv = self.fresh("fpext");
            let op = if val.reg.starts_with('%') {
                val.reg.clone()
            } else {
                val.reg.clone()
            };
            self.emit(&format!("  %{conv} = fpext float {op} to double"));
            val.reg = format!("%{conv}");
            val.ty = "double".into();
            return;
        }
        if val.ty == "i32" {
            let conv = self.fresh("sitofp");
            self.emit(&format!("  %{conv} = sitofp i32 {} to double", val.reg));
            val.reg = format!("%{conv}");
            val.ty = "double".into();
        }
    }

    pub(super) fn promote_to_float(&mut self, val: &mut ExprValue) {
        if val.ty == "float" {
            return;
        }
        if val.ty == "double" {
            let conv = self.fresh("fptrunc");
            self.emit(&format!("  %{conv} = fptrunc double {} to float", val.reg));
            val.reg = format!("%{conv}");
            val.ty = "float".into();
            return;
        }
        if val.ty == "i32" {
            let conv = self.fresh("sitofp");
            self.emit(&format!("  %{conv} = sitofp i32 {} to float", val.reg));
            val.reg = format!("%{conv}");
            val.ty = "float".into();
        }
    }

    pub(super) fn align_numeric_operands(&mut self, left: &mut ExprValue, right: &mut ExprValue) {
        if left.ty == "double" || right.ty == "double" {
            self.promote_to_double(left);
            self.promote_to_double(right);
        } else if left.ty == "float" || right.ty == "float" {
            self.promote_to_float(left);
            self.promote_to_float(right);
        }
    }

    pub(super) fn align_comparison_operands(&mut self, left: &mut ExprValue, right: &mut ExprValue) {
        if left.ty == "i1" && right.ty == "i32" {
            let z = self.fresh("zext");
            self.emit(&format!("  %{z} = zext i1 {} to i32", left.reg));
            left.reg = format!("%{z}");
            left.ty = "i32".into();
        } else if right.ty == "i1" && left.ty == "i32" {
            let z = self.fresh("zext");
            self.emit(&format!("  %{z} = zext i1 {} to i32", right.reg));
            right.reg = format!("%{z}");
            right.ty = "i32".into();
        } else {
            self.align_numeric_operands(left, right);
        }
    }

    pub(super) fn llvm_arith_op(op: BinaryOp, ty: &str) -> &'static str {
        if ty == "double" || ty == "float" {
            match op {
                BinaryOp::Add => "fadd",
                BinaryOp::Sub => "fsub",
                BinaryOp::Mul => "fmul",
                BinaryOp::Div => "fdiv",
                BinaryOp::Mod => "frem",
                _ => "fadd",
            }
        } else {
            match op {
                BinaryOp::Add => "add",
                BinaryOp::Sub => "sub",
                BinaryOp::Mul => "mul",
                BinaryOp::Div => "sdiv",
                BinaryOp::Mod => "srem",
                _ => "add",
            }
        }
    }

    pub(super) fn llvm_cmp_op(op: BinaryOp, ty: &str) -> &'static str {
        if ty == "double" || ty == "float" {
            match op {
                BinaryOp::Eq => "oeq",
                BinaryOp::Ne => "one",
                BinaryOp::Lt => "olt",
                BinaryOp::Gt => "ogt",
                BinaryOp::Le => "ole",
                BinaryOp::Ge => "oge",
                _ => "oeq",
            }
        } else {
            match op {
                BinaryOp::Eq => "eq",
                BinaryOp::Ne => "ne",
                BinaryOp::Lt => "slt",
                BinaryOp::Gt => "sgt",
                BinaryOp::Le => "sle",
                BinaryOp::Ge => "sge",
                _ => "eq",
            }
        }
    }

    pub(super) fn compile_binary(
        &mut self,
        bin: &BinaryExpr,
        env: &Env,
    ) -> ExprValue {
        let mut left = self.compile_expr(&bin.left, env);
        let mut right = self.compile_expr(&bin.right, env);
        let reg = self.fresh("bin");
        match bin.op {
            BinaryOp::Add => {
                if left.ty == "ptr" && right.ty == "i32" {
                    let gep = self.fresh("gep");
                    let p = self.materialize_ptr_reg(&left.reg);
                    self.emit(&format!(
                        "  %{gep} = getelementptr inbounds i32, ptr {p}, i32 {}",
                        right.reg
                    ));
                    return ExprValue {
                        reg: format!("%{gep}"),
                        ty: "ptr".into(),
                    };
                }
                if right.ty == "ptr" && left.ty == "i32" {
                    let gep = self.fresh("gep");
                    let p = self.materialize_ptr_reg(&right.reg);
                    self.emit(&format!(
                        "  %{gep} = getelementptr inbounds i32, ptr {p}, i32 {}",
                        left.reg
                    ));
                    return ExprValue {
                        reg: format!("%{gep}"),
                        ty: "ptr".into(),
                    };
                }
                if left.ty == "ptr" && right.ty == "ptr" {
                    return self.emit_strcat(&left, &right);
                }
                self.align_comparison_operands(&mut left, &mut right);
                let op = Self::llvm_arith_op(bin.op, &left.ty);
                self.emit(&format!(
                    "  %{reg} = {op} {}",
                    llvm_arith_rhs(&left.ty, &left.reg, &right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: left.ty,
                }
            }
            BinaryOp::Sub => {
                if left.ty == "ptr" && right.ty == "i32" {
                    let gep = self.fresh("gep");
                    let neg = self.fresh("neg");
                    let p = self.materialize_ptr_reg(&left.reg);
                    self.emit(&format!("  %{neg} = sub i32 0, {}", right.reg));
                    self.emit(&format!(
                        "  %{gep} = getelementptr inbounds i32, ptr {p}, i32 %{neg}"
                    ));
                    return ExprValue {
                        reg: format!("%{gep}"),
                        ty: "ptr".into(),
                    };
                }
                self.align_comparison_operands(&mut left, &mut right);
                let op = Self::llvm_arith_op(bin.op, &left.ty);
                self.emit(&format!(
                    "  %{reg} = {op} {}",
                    llvm_arith_rhs(&left.ty, &left.reg, &right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: left.ty,
                }
            }
            BinaryOp::Mul => {
                self.align_comparison_operands(&mut left, &mut right);
                let op = Self::llvm_arith_op(bin.op, &left.ty);
                self.emit(&format!(
                    "  %{reg} = {op} {}",
                    llvm_arith_rhs(&left.ty, &left.reg, &right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: left.ty,
                }
            }
            BinaryOp::Div => {
                self.align_comparison_operands(&mut left, &mut right);
                let op = Self::llvm_arith_op(bin.op, &left.ty);
                self.emit(&format!(
                    "  %{reg} = {op} {}",
                    llvm_arith_rhs(&left.ty, &left.reg, &right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: left.ty,
                }
            }
            BinaryOp::Mod => {
                self.align_comparison_operands(&mut left, &mut right);
                if left.ty == "i32" {
                    if let Some(d) = crate::const_mod::parse_i32_literal(&bin.right) {
                        if d > 0 {
                            return self.emit_i32_mod_by_positive_const(
                                &left,
                                d,
                                &bin.left,
                                env,
                            );
                        }
                    }
                }
                let op = Self::llvm_arith_op(bin.op, &left.ty);
                self.emit(&format!(
                    "  %{reg} = {op} {}",
                    llvm_arith_rhs(&left.ty, &left.reg, &right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: left.ty,
                }
            }
            BinaryOp::Shl | BinaryOp::Shr | BinaryOp::BitAnd | BinaryOp::BitOr | BinaryOp::BitXor => {
                self.align_comparison_operands(&mut left, &mut right);
                let op = match bin.op {
                    BinaryOp::Shl => "shl",
                    BinaryOp::Shr => "ashr",
                    BinaryOp::BitAnd => "and",
                    BinaryOp::BitOr => "or",
                    BinaryOp::BitXor => "xor",
                    _ => "add",
                };
                self.emit(&format!(
                    "  %{reg} = {op} {}",
                    llvm_arith_rhs(&left.ty, &left.reg, &right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: left.ty,
                }
            }
            BinaryOp::And => {
                self.emit(&format!(
                    "  %{reg} = and i1 {}, {}",
                    left.reg, right.reg
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::Or => {
                self.emit(&format!(
                    "  %{reg} = or i1 {}, {}",
                    left.reg, right.reg
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::Eq => {
                if self.should_compare_ptr_as_string(&bin.left, &bin.right, &left, &right, env) {
                    return self.compile_string_eq(&left, &right, true);
                }
                self.align_comparison_operands(&mut left, &mut right);
                let pred = Self::llvm_cmp_op(bin.op, &left.ty);
                let storage = llvm_storage_ty(&left.ty);
                let cmp = if left.ty == "double" || left.ty == "float" { "fcmp" } else { "icmp" };
                let ty_kw = if left.ty == "double" {
                    "double"
                } else if left.ty == "float" {
                    "float"
                } else {
                    storage
                };
                self.emit(&format!(
                    "  %{reg} = {cmp} {pred} {ty_kw} {}, {}",
                    llvm_cmp_operand(&left.reg),
                    llvm_cmp_operand(&right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::Ne => {
                if self.should_compare_ptr_as_string(&bin.left, &bin.right, &left, &right, env) {
                    return self.compile_string_eq(&left, &right, false);
                }
                self.align_comparison_operands(&mut left, &mut right);
                let pred = Self::llvm_cmp_op(bin.op, &left.ty);
                let storage = llvm_storage_ty(&left.ty);
                let cmp = if left.ty == "double" || left.ty == "float" { "fcmp" } else { "icmp" };
                let ty_kw = if left.ty == "double" {
                    "double"
                } else if left.ty == "float" {
                    "float"
                } else {
                    storage
                };
                self.emit(&format!(
                    "  %{reg} = {cmp} {pred} {ty_kw} {}, {}",
                    llvm_cmp_operand(&left.reg),
                    llvm_cmp_operand(&right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::Lt => {
                if self.should_compare_ptr_as_string(&bin.left, &bin.right, &left, &right, env) {
                    return self.compile_string_ord(&left, &right, bin.op);
                }
                self.align_comparison_operands(&mut left, &mut right);
                let pred = Self::llvm_cmp_op(bin.op, &left.ty);
                let storage = llvm_storage_ty(&left.ty);
                let cmp = if left.ty == "double" || left.ty == "float" { "fcmp" } else { "icmp" };
                let ty_kw = if left.ty == "double" {
                    "double"
                } else if left.ty == "float" {
                    "float"
                } else {
                    storage
                };
                self.emit(&format!(
                    "  %{reg} = {cmp} {pred} {ty_kw} {}, {}",
                    llvm_cmp_operand(&left.reg),
                    llvm_cmp_operand(&right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::Gt => {
                if self.should_compare_ptr_as_string(&bin.left, &bin.right, &left, &right, env) {
                    return self.compile_string_ord(&left, &right, bin.op);
                }
                self.align_comparison_operands(&mut left, &mut right);
                let pred = Self::llvm_cmp_op(bin.op, &left.ty);
                let storage = llvm_storage_ty(&left.ty);
                let cmp = if left.ty == "double" || left.ty == "float" { "fcmp" } else { "icmp" };
                let ty_kw = if left.ty == "double" {
                    "double"
                } else if left.ty == "float" {
                    "float"
                } else {
                    storage
                };
                self.emit(&format!(
                    "  %{reg} = {cmp} {pred} {ty_kw} {}, {}",
                    llvm_cmp_operand(&left.reg),
                    llvm_cmp_operand(&right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::Le => {
                if self.should_compare_ptr_as_string(&bin.left, &bin.right, &left, &right, env) {
                    return self.compile_string_ord(&left, &right, bin.op);
                }
                self.align_comparison_operands(&mut left, &mut right);
                let pred = Self::llvm_cmp_op(bin.op, &left.ty);
                let storage = llvm_storage_ty(&left.ty);
                let cmp = if left.ty == "double" || left.ty == "float" { "fcmp" } else { "icmp" };
                let ty_kw = if left.ty == "double" {
                    "double"
                } else if left.ty == "float" {
                    "float"
                } else {
                    storage
                };
                self.emit(&format!(
                    "  %{reg} = {cmp} {pred} {ty_kw} {}, {}",
                    llvm_cmp_operand(&left.reg),
                    llvm_cmp_operand(&right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::Ge => {
                if self.should_compare_ptr_as_string(&bin.left, &bin.right, &left, &right, env) {
                    return self.compile_string_ord(&left, &right, bin.op);
                }
                self.align_comparison_operands(&mut left, &mut right);
                let pred = Self::llvm_cmp_op(bin.op, &left.ty);
                let storage = llvm_storage_ty(&left.ty);
                let cmp = if left.ty == "double" || left.ty == "float" { "fcmp" } else { "icmp" };
                let ty_kw = if left.ty == "double" {
                    "double"
                } else if left.ty == "float" {
                    "float"
                } else {
                    storage
                };
                self.emit(&format!(
                    "  %{reg} = {cmp} {pred} {ty_kw} {}, {}",
                    llvm_cmp_operand(&left.reg),
                    llvm_cmp_operand(&right.reg)
                ));
                ExprValue {
                    reg: format!("%{reg}"),
                    ty: "i1".into(),
                }
            }
            BinaryOp::NullishCoalesce => right,
        }
    }
}

