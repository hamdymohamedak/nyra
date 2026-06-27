#![allow(unused_imports)]
//! Extern `fn` declarations and ABI type emission.
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
    pub(super) fn ensure_signature_types_from_extern(&mut self, ext: &ExternFn) {
        for p in &ext.params {
            self.ensure_abi_types_from_ann(&p.ty);
        }
        if let Some(ret) = &ext.return_type {
            self.ensure_abi_types_from_ann(ret);
        }
    }

    pub(super) fn ensure_signature_types_from_fn(&mut self, func: &Function) {
        for p in &func.params {
            self.ensure_abi_types_from_ann(&p.ty);
        }
        if let Some(ret) = &func.return_type {
            self.ensure_abi_types_from_ann(ret);
        }
    }

    pub(super) fn ensure_abi_types_from_ann(&mut self, ann: &TypeAnnotation) {
        match ann {
            TypeAnnotation::Tuple(elems) => {
                self.ensure_tuple_type(elems);
            }
            TypeAnnotation::Array { elem, .. } => self.ensure_abi_types_from_ann(elem),
            TypeAnnotation::Struct(name) if !self.enum_names.contains(name) => {
                if let Some(fields) = self.struct_fields.get(name).cloned() {
                    for (_, ty) in fields {
                        self.ensure_abi_types_from_ann(&ty);
                    }
                }
            }
            TypeAnnotation::FnPtr {
                params,
                return_type,
                ..
            } => {
                for p in params {
                    self.ensure_abi_types_from_ann(p);
                }
                if let Some(ret) = return_type {
                    self.ensure_abi_types_from_ann(ret);
                }
            }
            _ => {}
        }
    }

    pub(super) fn emit_extern_decl(&mut self, ext: &ExternFn) {
        let sret = ext.return_type.as_ref().and_then(|t| match t {
            TypeAnnotation::Struct(n) if self.repr_c_struct_uses_arm64_indirect(n) => {
                Some(n.clone())
            }
            _ => None,
        });
        let ret = ext
            .return_type
            .as_ref()
            .map(|t| self.llvm_extern_ret_type_of(t))
            .unwrap_or_else(|| "void".to_string());
        let mut param_types: Vec<String> = Vec::new();
        if let Some(n) = &sret {
            param_types.push(format!("%{n}* sret(%{n})"));
        }
        param_types.extend(
            ext.params
                .iter()
                .map(|p| self.llvm_extern_param_type_of(&p.ty)),
        );
        let sig = param_types
            .iter()
            .enumerate()
            .map(|(i, t)| format!("{t} %{i}"))
            .collect::<Vec<_>>()
            .join(", ");
        let c_sym = self
            .extern_c_symbols
            .get(&ext.name)
            .cloned()
            .unwrap_or_else(|| crate::runtime_map::c_symbol_for(&ext.name));
        if !self.declared_c_syms.insert(c_sym.clone()) {
            return;
        }
        self.skip_runtime_decls.insert(c_sym.clone());
        self.emit(&format!("declare {ret} @{c_sym}({sig})"));
    }
}

