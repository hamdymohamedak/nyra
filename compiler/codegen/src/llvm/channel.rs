#![allow(unused_imports)]
//! Single-thread stack ring-buffer channels (`NoEscape`).
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
    pub(super) fn ensure_local_channel_type(&mut self) {
        if self.local_channel_type_emitted {
            return;
        }
        self.emit_module(&format!(
            "{LOCAL_CHANNEL_TYPE} = type {{ [{LOCAL_CHANNEL_CAP} x i32], i32 }}"
        ));
        self.local_channel_type_emitted = true;
    }

    pub(super) fn emit_local_channel_alloc(&mut self) -> String {
        self.ensure_local_channel_type();
        let slot = self.fresh("lch");
        self.emit(&format!("  %{slot} = alloca {LOCAL_CHANNEL_TYPE}"));
        let len_gep = self.fresh("lch.len.gep");
        self.emit(&format!(
            "  %{len_gep} = getelementptr inbounds {LOCAL_CHANNEL_TYPE}, {LOCAL_CHANNEL_TYPE}* %{slot}, i32 0, i32 1"
        ));
        self.emit(&format!("  store i32 0, i32* %{len_gep}"));
        slot
    }

    pub(super) fn local_channel_len_gep(&mut self, slot: &str) -> String {
        let gep = self.fresh("lch.len.gep");
        self.emit(&format!(
            "  %{gep} = getelementptr inbounds {LOCAL_CHANNEL_TYPE}, {LOCAL_CHANNEL_TYPE}* %{slot}, i32 0, i32 1"
        ));
        gep
    }

    pub(super) fn local_channel_data_gep(&mut self, slot: &str, index_reg: &str) -> String {
        let gep = self.fresh("lch.data.gep");
        self.emit(&format!(
            "  %{gep} = getelementptr inbounds {LOCAL_CHANNEL_TYPE}, {LOCAL_CHANNEL_TYPE}* %{slot}, i32 0, i32 0, i32 {index_reg}"
        ));
        gep
    }

    pub(super) fn emit_local_channel_send(&mut self, slot: &str, val: &ExprValue) {
        self.ensure_local_channel_type();
        let len_gep = self.local_channel_len_gep(slot);
        let len = self.fresh("lch.len");
        self.emit(&format!("  %{len} = load i32, i32* %{len_gep}"));
        let cap_ok = self.fresh("lch.cap.ok");
        self.emit(&format!(
            "  %{cap_ok} = icmp slt i32 %{len}, {LOCAL_CHANNEL_CAP}"
        ));
        let ok_bb = self.fresh_label("lch.send.ok");
        let done_bb = self.fresh_label("lch.send.done");
        self.emit(&format!("  br i1 %{cap_ok}, label %{ok_bb}, label %{done_bb}"));
        self.emit_block_label(&ok_bb);
        let data_gep = self.local_channel_data_gep(slot, &format!("%{len}"));
        let val_reg = if val.reg.chars().all(|c| c.is_ascii_digit() || c == '-') {
            val.reg.clone()
        } else if val.reg.starts_with('%') {
            val.reg.clone()
        } else {
            format!("%{}", val.reg)
        };
        self.emit(&format!("  store i32 {val_reg}, i32* %{data_gep}"));
        let inc = self.fresh("lch.inc");
        self.emit(&format!("  %{inc} = add i32 %{len}, 1"));
        self.emit(&format!("  store i32 %{inc}, i32* %{len_gep}"));
        self.emit(&format!("  br label %{done_bb}"));
        self.emit_block_label(&done_bb);
    }

    pub(super) fn emit_local_channel_recv(&mut self, slot: &str) -> String {
        self.ensure_local_channel_type();
        let len_gep = self.local_channel_len_gep(slot);
        let len = self.fresh("lch.len");
        self.emit(&format!("  %{len} = load i32, i32* %{len_gep}"));
        let data0_gep = self.local_channel_data_gep(slot, "0");
        let val = self.fresh("lch.val");
        self.emit(&format!("  %{val} = load i32, i32* %{data0_gep}"));
        let has_more = self.fresh("lch.more");
        self.emit(&format!("  %{has_more} = icmp sgt i32 %{len}, 1"));
        let shift_bb = self.fresh_label("lch.shift");
        let done_bb = self.fresh_label("lch.recv.done");
        self.emit(&format!(
            "  br i1 %{has_more}, label %{shift_bb}, label %{done_bb}"
        ));
        self.emit_block_label(&shift_bb);
        let src = self.local_channel_data_gep(slot, "1");
        let bytes = self.fresh("lch.bytes");
        let dec = self.fresh("lch.dec");
        self.emit(&format!("  %{dec} = sub i32 %{len}, 1"));
        self.emit(&format!("  %{bytes} = mul i32 %{dec}, 4"));
        let bytes64 = self.fresh("lch.bytes64");
        self.emit(&format!("  %{bytes64} = sext i32 %{bytes} to i64"));
        self.emit(&format!(
            "  call void @llvm.memcpy.p0.p0.i64(i32* %{data0_gep}, i32* %{src}, i64 %{bytes64}, i1 false)"
        ));
        self.emit(&format!("  br label %{done_bb}"));
        self.emit_block_label(&done_bb);
        let new_len = self.fresh("lch.newlen");
        self.emit(&format!("  %{new_len} = sub i32 %{len}, 1"));
        self.emit(&format!("  store i32 %{new_len}, i32* %{len_gep}"));
        val
    }

    pub(super) fn resolve_local_channel_slot(&self, expr: &Expression, env: &Env) -> Option<String> {
        match expr {
            Expression::Variable { name, .. } => match env.get(name)? {
                Binding::LocalChannel { slot } => Some(slot.clone()),
                _ => None,
            },
            Expression::FieldAccess(fa) if fa.field == "handle" => {
                if let Expression::Variable { name, .. } = &fa.object {
                    match env.get(name)? {
                        Binding::LocalChannel { slot } => Some(slot.clone()),
                        _ => None,
                    }
                } else {
                    None
                }
            }
            _ => None,
        }
    }
}

