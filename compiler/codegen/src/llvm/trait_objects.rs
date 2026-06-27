//! Trait object vtables, boxing, and dynamic dispatch (LLVM).
use std::fmt::Write;

use ast::*;

use super::Codegen;
use super::util::{llvm_struct_size_bytes, llvm_type_ann_resolved, llvm_value_operand, struct_name_from_llvm_ty};

impl Codegen {
    pub(super) fn emit_trait_object_infrastructure(&mut self, program: &Program) {
        for trait_def in &program.traits {
            if trait_def.name == "Drop" || trait_def.name == "Clone" {
                continue;
            }
            let dyn_ty = format!("Dyn_{}", trait_def.name);
            if !self.struct_fields.contains_key(&dyn_ty) {
                continue;
            }
            for ti in &program.trait_impls {
                if ti.trait_name != trait_def.name {
                    continue;
                }
                self.emit_vtable_and_box(trait_def, ti);
            }
            for method in &trait_def.methods {
                self.emit_dyn_dispatch_fn(trait_def, method);
            }
            self.emit_dyn_drop_fn(trait_def);
        }
    }

    fn emit_vtable_and_box(&mut self, trait_def: &TraitDef, ti: &TraitImpl) {
        let trait_name = &trait_def.name;
        let type_name = &ti.type_name;
        let dyn_ty = format!("Dyn_{trait_name}");
        let struct_ty = format!("%{type_name}");
        let size = self.struct_byte_size(type_name);
        if size <= 0 {
            return;
        }

        let mut vtable_entries = Vec::new();
        for method in &trait_def.methods {
            let static_fn = format!("{trait_name}_{type_name}_{}", method.name);
            let thunk = format!("{trait_name}_dynthunk_{type_name}_{}", method.name);
            self.emit_method_thunk(&thunk, type_name, &static_fn, method);
            vtable_entries.push(format!("ptr @{thunk}"));
        }
        let drop_thunk = format!("{trait_name}_dynthunk_drop_{type_name}");
        self.emit_drop_thunk(&drop_thunk, type_name, &struct_ty);
        vtable_entries.push(format!("ptr @{drop_thunk}"));

        let vtable_name = format!("vtable_{trait_name}_{type_name}");
        self.emit_lines(&format!(
            "@{vtable_name} = constant [{} x ptr] [{}]",
            vtable_entries.len(),
            vtable_entries.join(", ")
        ));

        let box_fn = format!("{trait_name}_dyn_{type_name}");
        let mut body = String::new();
        writeln!(
            body,
            "define %{dyn_ty} @{box_fn}({struct_ty}* %val) {{"
        )
        .unwrap();
        writeln!(body, "entry:").unwrap();
        writeln!(
            body,
            "  %heap = call ptr @malloc(i64 {size})"
        )
        .unwrap();
        self.needs_malloc_decl = true;
        writeln!(
            body,
            "  call void @llvm.memcpy.p0.p0.i64(ptr %heap, ptr %val, i64 {size}, i1 false)"
        )
        .unwrap();
        writeln!(
            body,
            "  %dyn = insertvalue %{dyn_ty} undef, ptr %heap, 0"
        )
        .unwrap();
        writeln!(
            body,
            "  %dyn1 = insertvalue %{dyn_ty} %dyn, ptr @{vtable_name}, 1"
        )
        .unwrap();
        writeln!(body, "  ret %{dyn_ty} %dyn1").unwrap();
        writeln!(body, "}}").unwrap();
        self.emit_lines(&body);
        self.emit("");

        let ret = format!("%{dyn_ty}");
        self.call_returns.insert(box_fn.clone(), ret.clone());
    }

    fn emit_method_thunk(
        &mut self,
        thunk_name: &str,
        type_name: &str,
        static_fn: &str,
        method: &TraitMethodSig,
    ) {
        let struct_ty = format!("%{type_name}");
        let param_tys: Vec<String> = method
            .params
            .iter()
            .skip(1)
            .map(|p| llvm_type_ann_resolved(&p.ty, &self.struct_fields, &self.enum_names))
            .collect();
        let ret_ty = method
            .return_type
            .as_ref()
            .map(|t| llvm_type_ann_resolved(t, &self.struct_fields, &self.enum_names))
            .unwrap_or_else(|| "void".into());

        let mut sig_params = Vec::new();
        for (i, ty) in param_tys.iter().enumerate() {
            sig_params.push(format!("{ty} %arg{i}"));
        }
        let call_args = {
            let mut args = vec![format!("{struct_ty}* %data")];
            for i in 0..param_tys.len() {
                args.push(format!("{} %arg{i}", param_tys[i]));
            }
            args.join(", ")
        };

        let mut body = String::new();
        writeln!(
            body,
            "define {ret_ty} @{thunk_name}(ptr %data{}) {{",
            if sig_params.is_empty() {
                String::new()
            } else {
                format!(", {}", sig_params.join(", "))
            }
        )
        .unwrap();
        writeln!(body, "entry:").unwrap();
        if ret_ty == "void" {
            writeln!(body, "  call void @{static_fn}({call_args})").unwrap();
            writeln!(body, "  ret void").unwrap();
        } else {
            writeln!(
                body,
                "  %r = call {ret_ty} @{static_fn}({call_args})"
            )
            .unwrap();
            writeln!(body, "  ret {ret_ty} %r").unwrap();
        }
        writeln!(body, "}}").unwrap();
        self.emit_lines(&body);
        self.emit("");
    }

    fn emit_drop_thunk(&mut self, thunk_name: &str, type_name: &str, struct_ty: &str) {
        let mut body = String::new();
        writeln!(
            body,
            "define void @{thunk_name}(ptr %data) {{"
        )
        .unwrap();
        writeln!(body, "entry:").unwrap();
        if self.drop_plan.custom_drop_fns.contains_key(type_name) {
            let drop_fn = self
                .drop_plan
                .custom_drop_fns
                .get(type_name)
                .cloned()
                .unwrap_or_else(|| format!("Drop_{type_name}_drop"));
            writeln!(
                body,
                "  call void @{drop_fn}({struct_ty}* %data)"
            )
            .unwrap();
        }
        writeln!(body, "  call void @free(ptr %data)").unwrap();
        self.needs_malloc_decl = true;
        writeln!(body, "  ret void").unwrap();
        writeln!(body, "}}").unwrap();
        self.emit_lines(&body);
        self.emit("");
    }

    fn emit_dyn_drop_fn(&mut self, trait_def: &TraitDef) {
        let trait_name = &trait_def.name;
        let dyn_ty = format!("Dyn_{trait_name}");
        let fn_name = format!("__dyn_{trait_name}_drop");
        let drop_index = trait_def.methods.len() as i32;

        let mut body = String::new();
        writeln!(
            body,
            "define void @{fn_name}(%{dyn_ty}* %obj) {{"
        )
        .unwrap();
        writeln!(body, "entry:").unwrap();
        writeln!(
            body,
            "  %data_ptr = getelementptr inbounds %{dyn_ty}, %{dyn_ty}* %obj, i32 0, i32 0"
        )
        .unwrap();
        writeln!(body, "  %data = load ptr, ptr %data_ptr").unwrap();
        writeln!(
            body,
            "  %vt_ptr = getelementptr inbounds %{dyn_ty}, %{dyn_ty}* %obj, i32 0, i32 1"
        )
        .unwrap();
        writeln!(body, "  %vt = load ptr, ptr %vt_ptr").unwrap();
        writeln!(
            body,
            "  %drop_ptr = getelementptr ptr, ptr %vt, i32 {drop_index}"
        )
        .unwrap();
        writeln!(
            body,
            "  %drop_fn = load void (ptr)*, void (ptr)** %drop_ptr"
        )
        .unwrap();
        writeln!(body, "  call void %drop_fn(ptr %data)").unwrap();
        writeln!(body, "  ret void").unwrap();
        writeln!(body, "}}").unwrap();
        self.emit_lines(&body);
        self.emit("");
    }

    fn emit_dyn_dispatch_fn(&mut self, trait_def: &TraitDef, method: &TraitMethodSig) {
        let trait_name = &trait_def.name;
        let dyn_ty = format!("Dyn_{trait_name}");
        let fn_name = format!("__dyn_{trait_name}_{}", method.name);
        let method_index = trait_def
            .methods
            .iter()
            .position(|m| m.name == method.name)
            .unwrap_or(0) as i32;
        let param_tys: Vec<String> = method
            .params
            .iter()
            .skip(1)
            .map(|p| llvm_type_ann_resolved(&p.ty, &self.struct_fields, &self.enum_names))
            .collect();
        let ret_ty = method
            .return_type
            .as_ref()
            .map(|t| llvm_type_ann_resolved(t, &self.struct_fields, &self.enum_names))
            .unwrap_or_else(|| "void".into());

        let mut sig_params = vec![format!("%{dyn_ty}* %obj")];
        for (i, ty) in param_tys.iter().enumerate() {
            sig_params.push(format!("{ty} %arg{i}"));
        }

        let mut fn_ptr_sig = format!("{ret_ty} (ptr");
        for ty in &param_tys {
            write!(fn_ptr_sig, ", {ty}").unwrap();
        }
        fn_ptr_sig.push(')');

        let mut call_args = vec!["ptr %data".to_string()];
        for i in 0..param_tys.len() {
            call_args.push(format!("{} %arg{i}", param_tys[i]));
        }

        let mut body = String::new();
        writeln!(
            body,
            "define {ret_ty} @{fn_name}({}) {{",
            sig_params.join(", ")
        )
        .unwrap();
        writeln!(body, "entry:").unwrap();
        writeln!(
            body,
            "  %data_ptr = getelementptr inbounds %{dyn_ty}, %{dyn_ty}* %obj, i32 0, i32 0"
        )
        .unwrap();
        writeln!(body, "  %data = load ptr, ptr %data_ptr").unwrap();
        writeln!(
            body,
            "  %vt_ptr = getelementptr inbounds %{dyn_ty}, %{dyn_ty}* %obj, i32 0, i32 1"
        )
        .unwrap();
        writeln!(body, "  %vt = load ptr, ptr %vt_ptr").unwrap();
        writeln!(
            body,
            "  %fn_ptr = getelementptr ptr, ptr %vt, i32 {method_index}"
        )
        .unwrap();
        writeln!(body, "  %fn = load {fn_ptr_sig}*, {fn_ptr_sig}** %fn_ptr").unwrap();
        if ret_ty == "void" {
            writeln!(
                body,
                "  call void %fn({})",
                call_args.join(", ")
            )
            .unwrap();
            writeln!(body, "  ret void").unwrap();
        } else {
            writeln!(
                body,
                "  %r = call {ret_ty} %fn({})",
                call_args.join(", ")
            )
            .unwrap();
            writeln!(body, "  ret {ret_ty} %r").unwrap();
        }
        writeln!(body, "}}").unwrap();
        self.emit_lines(&body);
        self.emit("");
        self.call_returns.insert(fn_name, ret_ty);
    }

    fn emit_lines(&mut self, text: &str) {
        for line in text.lines() {
            self.emit(line);
        }
    }

    pub(super) fn compile_trait_object_box(
        &mut self,
        trait_name: &str,
        expr: &Expression,
        env: &super::Env,
    ) -> super::ExprValue {
        let inner = self.compile_expr(expr, env);
        let concrete = struct_name_from_llvm_ty(&inner.ty)
            .or_else(|| {
                if inner.ty.starts_with('%') && !inner.ty.ends_with('*') {
                    Some(inner.ty.trim_start_matches('%').to_string())
                } else {
                    None
                }
            })
            .unwrap_or_else(|| "Unknown".into());
        let box_fn = format!("{trait_name}_dyn_{concrete}");
        let dyn_ty = format!("%Dyn_{trait_name}");
        let struct_ptr = if inner.ty.ends_with('*') {
            llvm_value_operand(&self.materialize_ptr_reg(&inner.reg))
        } else {
            let slot = self.materialize_struct_ssa_slot(&inner);
            format!("%{slot}")
        };
        let struct_ty = format!("%{concrete}");
        let reg = self.fresh("dynbox");
        self.emit(&format!(
            "  %{reg} = call {dyn_ty} @{box_fn}({struct_ty}* {struct_ptr})"
        ));
        super::ExprValue {
            reg: format!("%{reg}"),
            ty: dyn_ty,
        }
    }

    fn struct_byte_size(&self, name: &str) -> i64 {
        let Some(fields) = self.struct_fields.get(name) else {
            return 0;
        };
        let llvm_fields: Vec<String> = fields
            .iter()
            .map(|(_, ty)| llvm_type_ann_resolved(ty, &self.struct_fields, &self.enum_names))
            .collect();
        llvm_struct_size_bytes(&llvm_fields)
    }
}
