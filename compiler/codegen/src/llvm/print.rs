#![allow(unused_imports)]
//! Formatted output (`print` / `println`) and ANSI color prefixes.
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
    escape_string, host_target_triple, is_array_ty, is_string_builtin_method, llvm_arith_rhs,
    llvm_binop_operand, llvm_cmp_operand, llvm_ptr, llvm_ptr_reg, llvm_storage_ty, llvm_string_len,
    llvm_value_operand, llvm_struct_size_bytes, llvm_type_ann_resolved, llvm_ty_to_ann,
    resolve_struct_field_name, struct_name_from_llvm_ty, struct_ptr_type, struct_value_type,
    is_struct_pointer_type,
};

impl Codegen {
    pub(super) fn compile_print_stmt(&mut self, stmt: &PrintStmt, env: &mut Env) {
        if let Some(color) = &stmt.color {
            self.emit_color_prefix(color, env);
        }
        self.compile_print_args(&stmt.args, env);
        if stmt.color.is_some() {
            self.emit_ansi_reset();
        }
    }

    pub(super) fn emit_ansi_write(&mut self, ansi: &str) {
        let idx = self.intern_string(ansi);
        let ptr = self.fresh("ansi");
        self.emit(&format!(
            "  %{ptr} = getelementptr inbounds i8, ptr @.str.{idx}, i64 0"
        ));
        let fmt_idx = self.intern_string("%s");
        let fmt_ptr = self.fresh("fmt");
        self.emit(&format!(
            "  %{fmt_ptr} = getelementptr inbounds i8, ptr @.str.{fmt_idx}, i64 0"
        ));
        self.emit(&format!(
            "  call i32 (ptr, ...) @printf(ptr %{fmt_ptr}, ptr %{ptr})"
        ));
    }

    pub(super) fn emit_ansi_reset(&mut self) {
        self.emit_ansi_write("\x1b[0m");
    }

    pub(super) fn static_color_spec(expr: &Expression, env: &Env) -> Option<String> {
        match expr {
            Expression::Literal(Literal::String(s)) => color_spec_to_ansi(s),
            Expression::Variable { name, .. } if !env.contains_key(name) => color_spec_to_ansi(name),
            _ => None,
        }
    }

    pub(super) fn emit_color_prefix(&mut self, color: &Expression, env: &mut Env) {
        if let Some(ansi) = Self::static_color_spec(color, env) {
            self.emit_ansi_write(&ansi);
            return;
        }
        let spec = self.compile_expr(color, env);
        let spec_ptr = self.materialize_ptr_reg(&spec.reg);
        let prefix = self.fresh("color");
        self.emit(&format!("  %{prefix} = call ptr @color_ansi(ptr {spec_ptr})"));
        let fmt_idx = self.intern_string("%s");
        let fmt_ptr = self.fresh("fmt");
        self.emit(&format!(
            "  %{fmt_ptr} = getelementptr inbounds i8, ptr @.str.{fmt_idx}, i64 0"
        ));
        self.emit(&format!(
            "  call i32 (ptr, ...) @printf(ptr %{fmt_ptr}, ptr %{prefix})"
        ));
        self.used_runtime.insert("color_ansi".into());
    }

    pub(super) fn compile_print_args(
        &mut self,
        args: &[Expression],
        env: &mut Env,
    ) {
        if args.len() == 1 {
            if let Expression::Literal(Literal::String(s)) = &args[0] {
                let idx = self.intern_string(s);
                let str_ptr = self.fresh("str");
                self.emit(&format!(
                    "  %{str_ptr} = getelementptr inbounds i8, ptr @.str.{idx}, i64 0"
                ));
                self.emit(&format!("  call i32 @puts(ptr %{str_ptr})"));
                self.uses_puts = true;
                return;
            }
        }
        let mut fmt = String::new();
        let mut printf_args: Vec<(String, String)> = Vec::new();
        for arg in args {
            self.append_printf_segments(arg, env, &mut fmt, &mut printf_args);
        }
        fmt.push('\n');
        let fmt_idx = self.intern_string(&fmt);
        let fmt_ptr = self.fresh("fmt");
        self.emit(&format!(
            "  %{fmt_ptr} = getelementptr inbounds i8, ptr @.str.{fmt_idx}, i64 0"
        ));
        if printf_args.is_empty() {
            self.emit(&format!("  call i32 (ptr, ...) @printf(ptr %{fmt_ptr})"));
            return;
        }
        let arg_list = printf_args
            .iter()
            .map(|(ty, reg)| format!("{ty} {reg}"))
            .collect::<Vec<_>>()
            .join(", ");
        self.emit(&format!(
            "  call i32 (ptr, ...) @printf(ptr %{fmt_ptr}, {arg_list})"
        ));
    }

    pub(super) fn append_printf_segments(
        &mut self,
        expr: &Expression,
        env: &Env,
        fmt: &mut String,
        args: &mut Vec<(String, String)>,
    ) {
        match expr {
            Expression::TemplateLiteral(t) => {
                for part in &t.parts {
                    match part {
                        TemplatePart::Static(text) => {
                            self.append_printf_static(text, fmt, args);
                        }
                        TemplatePart::Interpolation(inner) => {
                            self.append_printf_expr(inner, env, fmt, args);
                        }
                    }
                }
            }
            other => self.append_printf_expr(other, env, fmt, args),
        }
    }

    pub(super) fn append_printf_static(&mut self, text: &str, fmt: &mut String, args: &mut Vec<(String, String)>) {
        fmt.push_str("%s");
        let idx = self.intern_string(text);
        let reg = self.fresh("str");
        self.emit(&format!(
            "  %{reg} = getelementptr inbounds i8, ptr @.str.{idx}, i64 0"
        ));
        args.push(("ptr".into(), format!("%{reg}")));
    }

    pub(super) fn emit_array_debug_string(&mut self, obj: &ExprValue) -> ExprValue {
        let n = array_len_from_ty(&obj.ty).expect("typechecked fixed array");
        let elem = array_elem_from_ty(&obj.ty).unwrap_or_else(|| "i32".into());
        let arr_ptr = self.materialize_array_ptr(obj);
        let src_elem = self.fresh("arr.dbg.gep");
        self.emit(&format!(
            "  %{src_elem} = getelementptr inbounds {}, {}* {arr_ptr}, i32 0, i32 0",
            obj.ty, obj.ty
        ));
        let out = self.fresh("arr.dbg");
        let (rt_name, call) = match elem.as_str() {
            "double" => (
                "array_f64_debug_string",
                format!(
                    "  %{out} = call ptr @array_f64_debug_string(double* %{src_elem}, i32 {n})"
                ),
            ),
            "float" => (
                "array_f32_debug_string",
                format!(
                    "  %{out} = call ptr @array_f32_debug_string(float* %{src_elem}, i32 {n})"
                ),
            ),
            "i1" => {
                let cast = self.fresh("arr.dbg.cast");
                self.emit(&format!(
                    "  %{cast} = bitcast i1* %{src_elem} to i8*"
                ));
                (
                    "array_bool_debug_string",
                    format!(
                        "  %{out} = call ptr @array_bool_debug_string(i8* %{cast}, i32 {n})"
                    ),
                )
            }
            "ptr" | "i8*" => (
                "array_str_debug_string",
                format!("  %{out} = call ptr @array_str_debug_string(ptr %{src_elem}, i32 {n})"),
            ),
            _ => (
                "array_i32_debug_string",
                format!("  %{out} = call ptr @array_i32_debug_string(i32* %{src_elem}, i32 {n})"),
            ),
        };
        self.emit_runtime_call(rt_name, &call);
        ExprValue {
            reg: format!("%{out}"),
            ty: "ptr".into(),
        }
    }

    pub(super) fn append_printf_expr(
        &mut self,
        expr: &Expression,
        env: &Env,
        fmt: &mut String,
        args: &mut Vec<(String, String)>,
    ) {
        let val = self.compile_expr(expr, env);
        if is_array_ty(&val.ty) {
            let formatted = self.emit_array_debug_string(&val);
            fmt.push_str("%s");
            args.push(("ptr".into(), self.materialize_ptr_reg(&formatted.reg)));
            return;
        }
        if val.ty == "ptr" || val.ty == "i8*" {
            fmt.push_str("%s");
            args.push(("ptr".into(), self.materialize_ptr_reg(&val.reg)));
        } else if val.ty == "char" {
            fmt.push_str("%c");
            args.push(("i32".into(), val.reg.clone()));
        } else if val.ty == "i64" {
            fmt.push_str("%lld");
            args.push(("i64".into(), val.reg.clone()));
        } else if val.ty == "float" {
            fmt.push_str("%g");
            let op = llvm_value_operand(&val.reg);
            let conv = self.fresh("fpext");
            self.emit(&format!("  %{conv} = fpext float {op} to double"));
            args.push(("double".into(), format!("%{conv}")));
        } else if val.ty == "double" {
            fmt.push_str("%g");
            args.push(("double".into(), val.reg.clone()));
        } else if val.ty == "i1" {
            fmt.push_str("%d");
            let ext = self.fresh("zext");
            self.emit(&format!("  %{ext} = zext i1 {} to i32", val.reg));
            args.push(("i32".into(), format!("%{ext}")));
        } else {
            fmt.push_str("%d");
            args.push(("i32".into(), val.reg));
        }
    }

    pub(super) fn compile_buffered_io_args(
        &mut self,
        args: &[Expression],
        env: &Env,
        newline: bool,
    ) {
        if args.is_empty() {
            return;
        }
        for (idx, arg) in args.iter().enumerate() {
            let last = idx + 1 == args.len();
            self.compile_buffered_io_segments(arg, env, newline && last);
        }
    }

    pub(super) fn compile_buffered_io_segments(
        &mut self,
        expr: &Expression,
        env: &Env,
        newline: bool,
    ) {
        match expr {
            Expression::TemplateLiteral(t) => {
                let parts: Vec<_> = t.parts.iter().collect();
                for (idx, part) in parts.iter().enumerate() {
                    let last = idx + 1 == parts.len();
                    match part {
                        TemplatePart::Static(text) => {
                            let idx = self.intern_string(text);
                            let reg = self.fresh("str");
                            self.emit(&format!(
                                "  %{reg} = getelementptr inbounds i8, ptr @.str.{idx}, i64 0"
                            ));
                            let callee = if newline && last {
                                "stdout_writeln_str"
                            } else {
                                "stdout_write_str"
                            };
                            self.emit(&format!("  call void @{callee}(ptr %{reg})"));
                        }
                        TemplatePart::Interpolation(inner) => {
                            self.compile_buffered_io(inner, env, newline && last);
                        }
                    }
                }
            }
            other => self.compile_buffered_io(other, env, newline),
        }
    }

    pub(super) fn compile_string_piece(
        &mut self,
        expr: &Expression,
        env: &Env,
    ) -> (ExprValue, bool) {
        match expr {
            Expression::Literal(Literal::String(s)) => {
                let idx = self.intern_string(s);
                let reg = self.fresh("str");
                self.emit(&format!(
                    "  %{reg} = getelementptr inbounds i8, ptr @.str.{idx}, i64 0"
                ));
                (
                    ExprValue {
                        reg: format!("%{reg}"),
                        ty: "ptr".into(),
                    },
                    false,
                )
            }
            Expression::TemplateLiteral(t) => {
                let value = self.compile_template_literal(t, env);
                (value, true)
            }
            other => {
                let val = self.compile_expr(other, env);
                if is_array_ty(&val.ty) {
                    (self.emit_array_debug_string(&val), true)
                } else if val.ty == "ptr" || val.ty == "i8*" {
                    (val, false)
                } else if val.ty == "i64" {
                    (self.emit_i64_to_string(&val.reg, &val.ty), true)
                } else {
                    (self.emit_i32_to_string(&val.reg, &val.ty), true)
                }
            }
        }
    }
}

