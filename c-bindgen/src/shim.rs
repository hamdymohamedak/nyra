//! C / C++ shim wrappers for signatures that cannot map directly to Nyra FFI,
//! and stable `extern "C"` bridges for C++-linkage symbols.

use clang::{Accessibility, Entity, EntityKind, Language, Type, TypeKind};

use crate::names;
use crate::types::NyraType;

#[derive(Debug, Clone)]
pub struct CShimFn {
    pub nyra_name: String,
    pub nyra_params: Vec<(String, NyraType)>,
    pub nyra_return: NyraType,
    /// Full function definition (C or `extern "C"` C++), without trailing semicolon after `}`.
    pub c_definition: String,
}

/// Build a simplified Nyra-facing wrapper when direct mapping fails (C mode).
pub fn try_shim_function(entity: &Entity, name: &str) -> Option<CShimFn> {
    if entity.is_variadic() {
        return None;
    }
    let ret_ty = entity.get_result_type()?;
    let ny_ret = map_shim_type(&ret_ty, false);

    let mut ny_params = Vec::new();
    let mut c_param_decls = Vec::new();
    let mut call_args = Vec::new();

    if let Some(args) = entity.get_arguments() {
        for (i, arg) in args.into_iter().enumerate() {
            let arg_ty = arg.get_type()?;
            let ny_ty = map_shim_type(&arg_ty, true);
            let pname = arg
                .get_name()
                .filter(|n| !n.is_empty())
                .unwrap_or_else(|| format!("arg{i}"));
            let pname = names::sanitize_identifier(&pname);
            ny_params.push((pname.clone(), ny_ty));
            c_param_decls.push(format!("{} {}", shim_c_type(&arg_ty), pname));
            call_args.push(cast_to_c(&arg_ty, &pname));
        }
    }

    let c_ret = shim_c_return_type(&ret_ty);
    let shim_name = format!("nyra_shim_{name}");
    let params_joined = c_param_decls.join(", ");
    let call_joined = call_args.join(", ");
    let c_body = if ny_ret == NyraType::Void {
        format!("{c_ret} {shim_name}({params_joined}) {{\n    {name}({call_joined});\n}}")
    } else {
        format!(
            "{c_ret} {shim_name}({params_joined}) {{\n    return {name}({call_joined});\n}}"
        )
    };

    Some(CShimFn {
        nyra_name: shim_name,
        nyra_params: ny_params,
        nyra_return: ny_ret,
        c_definition: c_body,
    })
}

/// Wrap a C++-linkage free function in a stable `extern "C"` symbol Nyra can link.
pub fn try_cxx_extern_c_function(entity: &Entity, spelling: &str) -> Option<CShimFn> {
    if entity.is_variadic() || is_operator_name(spelling) {
        return None;
    }
    if has_c_linkage(entity) {
        return None;
    }
    if !is_public(entity) {
        return None;
    }
    let ret_ty = entity.get_result_type()?;
    if !is_cxx_shim_safe_type(&ret_ty) {
        return None;
    }
    let ny_ret = map_shim_type(&ret_ty, false);
    let callee = cxx_qualified_name(entity)?;

    let mut ny_params = Vec::new();
    let mut c_param_decls = Vec::new();
    let mut call_args = Vec::new();

    if let Some(args) = entity.get_arguments() {
        for (i, arg) in args.into_iter().enumerate() {
            let arg_ty = arg.get_type()?;
            if !is_cxx_shim_safe_type(&arg_ty) {
                return None;
            }
            let ny_ty = map_shim_type(&arg_ty, true);
            let pname = arg
                .get_name()
                .filter(|n| !n.is_empty())
                .unwrap_or_else(|| format!("arg{i}"));
            let pname = names::sanitize_identifier(&pname);
            ny_params.push((pname.clone(), ny_ty));
            c_param_decls.push(format!("{} {}", shim_c_type(&arg_ty), pname));
            call_args.push(cast_to_cxx(&arg_ty, &pname));
        }
    }

    let c_ret = shim_c_return_type(&ret_ty);
    let shim_name = names::sanitize_identifier(spelling);
    let params_joined = c_param_decls.join(", ");
    let call_joined = call_args.join(", ");
    let body = if ny_ret == NyraType::Void {
        format!(
            "extern \"C\" {c_ret} {shim_name}({params_joined}) {{\n    {callee}({call_joined});\n}}"
        )
    } else {
        format!(
            "extern \"C\" {c_ret} {shim_name}({params_joined}) {{\n    return ({c_ret}){callee}({call_joined});\n}}"
        )
    };

    Some(CShimFn {
        nyra_name: shim_name,
        nyra_params: ny_params,
        nyra_return: ny_ret,
        c_definition: body,
    })
}

/// Wrap a simple non-static C++ method as `Class_method(self, …)`.
pub fn try_cxx_extern_c_method(entity: &Entity) -> Option<CShimFn> {
    if entity.get_kind() != EntityKind::Method {
        return None;
    }
    if entity.is_static_method()
        || entity.is_virtual_method()
        || entity.is_pure_virtual_method()
        || entity.is_defaulted()
        || entity.is_variadic()
    {
        return None;
    }
    if !is_public(entity) {
        return None;
    }
    let method_name = entity.get_name()?;
    if is_operator_name(&method_name) || method_name.starts_with('~') {
        return None;
    }
    let class = entity.get_semantic_parent()?;
    if !matches!(
        class.get_kind(),
        EntityKind::ClassDecl | EntityKind::StructDecl
    ) {
        return None;
    }
    let class_name = class.get_name().filter(|n| !n.is_empty())?;
    let class_qual = cxx_qualified_name(&class).unwrap_or(class_name.clone());

    let ret_ty = entity.get_result_type()?;
    if !is_cxx_shim_safe_type(&ret_ty) {
        return None;
    }
    let ny_ret = map_shim_type(&ret_ty, false);

    let mut ny_params = vec![("self_".into(), NyraType::Ptr)];
    let mut c_param_decls = vec!["void *self_".to_string()];
    let mut call_args = Vec::new();

    if let Some(args) = entity.get_arguments() {
        for (i, arg) in args.into_iter().enumerate() {
            let arg_ty = arg.get_type()?;
            if !is_cxx_shim_safe_type(&arg_ty) {
                return None;
            }
            let ny_ty = map_shim_type(&arg_ty, true);
            let pname = arg
                .get_name()
                .filter(|n| !n.is_empty())
                .unwrap_or_else(|| format!("arg{i}"));
            let pname = names::sanitize_identifier(&pname);
            ny_params.push((pname.clone(), ny_ty));
            c_param_decls.push(format!("{} {}", shim_c_type(&arg_ty), pname));
            call_args.push(cast_to_cxx(&arg_ty, &pname));
        }
    }

    let shim_name = names::sanitize_identifier(&format!("{class_name}_{method_name}"));
    let c_ret = shim_c_return_type(&ret_ty);
    let params_joined = c_param_decls.join(", ");
    let call_joined = call_args.join(", ");
    let invoke = if entity.is_const_method() {
        if call_joined.is_empty() {
            format!("reinterpret_cast<const {class_qual}*>(self_)->{method_name}()")
        } else {
            format!(
                "reinterpret_cast<const {class_qual}*>(self_)->{method_name}({call_joined})"
            )
        }
    } else if call_joined.is_empty() {
        format!("reinterpret_cast<{class_qual}*>(self_)->{method_name}()")
    } else {
        format!("reinterpret_cast<{class_qual}*>(self_)->{method_name}({call_joined})")
    };

    let body = if ny_ret == NyraType::Void {
        format!("extern \"C\" {c_ret} {shim_name}({params_joined}) {{\n    {invoke};\n}}")
    } else {
        format!(
            "extern \"C\" {c_ret} {shim_name}({params_joined}) {{\n    return ({c_ret}){invoke};\n}}"
        )
    };

    Some(CShimFn {
        nyra_name: shim_name,
        nyra_params: ny_params,
        nyra_return: ny_ret,
        c_definition: body,
    })
}

pub fn emit_shim_c(header_include: &str, shims: &[CShimFn]) -> String {
    let mut out = String::from(
        "/* Auto-generated by `nyra bind c` — do not edit. */\n\
         #include <stdint.h>\n",
    );
    out.push_str(&format!("#include \"{header_include}\"\n\n"));
    for shim in shims {
        out.push_str(&shim.c_definition);
        out.push_str("\n\n");
    }
    out
}

pub fn emit_shim_cxx(header_include: &str, shims: &[CShimFn]) -> String {
    let mut out = String::from(
        "/* Auto-generated by `nyra bind` (C++ interop) — do not edit. */\n\
         #include <stdint.h>\n\
         #include <cstddef>\n",
    );
    out.push_str(&format!("#include \"{header_include}\"\n\n"));
    for shim in shims {
        out.push_str(&shim.c_definition);
        out.push_str("\n\n");
    }
    out
}

pub fn has_c_linkage(entity: &Entity) -> bool {
    if entity.get_language() == Some(Language::C) {
        return true;
    }
    let Some(name) = entity.get_name() else {
        return false;
    };
    if let Some(mangled) = entity.get_mangled_name() {
        if mangled == name || mangled == format!("_{name}") {
            return true;
        }
        // Itanium C symbols are unmangled; C++ starts with _Z / __Z.
        if !mangled.contains("_Z") && !mangled.starts_with("__Z") && mangled.ends_with(&name) {
            // Conservative: still treat as possibly C if no Itanium marker.
            if !mangled.chars().any(|c| c.is_ascii_digit()) {
                return true;
            }
        }
    }
    let mut parent = entity.get_semantic_parent();
    while let Some(p) = parent {
        if p.get_kind() == EntityKind::LinkageSpec {
            // clang-rs does not expose C vs C++ on LinkageSpec; Language::C above covers most.
            return entity.get_language() != Some(Language::Cpp);
        }
        parent = p.get_semantic_parent();
    }
    false
}

pub fn cxx_qualified_name(entity: &Entity) -> Option<String> {
    let mut parts = Vec::new();
    let name = entity.get_name().filter(|n| !n.is_empty())?;
    parts.push(name);
    let mut parent = entity.get_semantic_parent();
    while let Some(p) = parent {
        match p.get_kind() {
            EntityKind::Namespace
            | EntityKind::ClassDecl
            | EntityKind::StructDecl
            | EntityKind::ClassTemplate => {
                if let Some(n) = p.get_name().filter(|n| !n.is_empty()) {
                    parts.push(n);
                }
            }
            EntityKind::TranslationUnit | EntityKind::LinkageSpec => break,
            _ => {}
        }
        parent = p.get_semantic_parent();
    }
    parts.reverse();
    Some(parts.join("::"))
}

fn is_operator_name(name: &str) -> bool {
    name.starts_with("operator") || name.contains("operator ")
}

fn is_public(entity: &Entity) -> bool {
    match entity.get_accessibility() {
        None | Some(Accessibility::Public) => true,
        Some(_) => false,
    }
}

/// Types we can put on an `extern "C"` boundary without STL / by-value classes.
fn is_cxx_shim_safe_type(ty: &Type) -> bool {
    let t = ty.get_canonical_type();
    match t.get_kind() {
        TypeKind::Void
        | TypeKind::Bool
        | TypeKind::CharS
        | TypeKind::SChar
        | TypeKind::CharU
        | TypeKind::UChar
        | TypeKind::Short
        | TypeKind::UShort
        | TypeKind::Int
        | TypeKind::UInt
        | TypeKind::Long
        | TypeKind::ULong
        | TypeKind::LongLong
        | TypeKind::ULongLong
        | TypeKind::Float
        | TypeKind::Double
        | TypeKind::LongDouble
        | TypeKind::Enum
        | TypeKind::Pointer => true,
        TypeKind::Typedef | TypeKind::Elaborated | TypeKind::Attributed => {
            is_cxx_shim_safe_type(&t.get_canonical_type())
        }
        TypeKind::ConstantArray | TypeKind::IncompleteArray => false,
        TypeKind::LValueReference | TypeKind::RValueReference | TypeKind::Record => false,
        _ => false,
    }
}

fn map_shim_type(ty: &Type, is_param: bool) -> NyraType {
    match ty.get_kind() {
        TypeKind::Void => NyraType::Void,
        TypeKind::Bool => NyraType::Bool,
        TypeKind::CharS | TypeKind::SChar | TypeKind::CharU | TypeKind::UChar
        | TypeKind::Short | TypeKind::Int => NyraType::Int("i32"),
        TypeKind::UShort | TypeKind::UInt => NyraType::Int("u32"),
        TypeKind::Long | TypeKind::LongLong => NyraType::Int("i64"),
        TypeKind::ULong | TypeKind::ULongLong => NyraType::Int("u64"),
        TypeKind::Float => NyraType::F32,
        TypeKind::Double | TypeKind::LongDouble => NyraType::F64,
        TypeKind::Pointer => {
            let pointee = ty.get_pointee_type();
            if let Some(pt) = pointee {
                let pk = pt.get_kind();
                if pk == TypeKind::CharS || pk == TypeKind::SChar || pk == TypeKind::CharU {
                    return NyraType::String;
                }
            }
            NyraType::Ptr
        }
        TypeKind::ConstantArray | TypeKind::IncompleteArray if is_param => NyraType::Ptr,
        TypeKind::Typedef | TypeKind::Elaborated => {
            map_shim_type(&ty.get_canonical_type(), is_param)
        }
        _ => NyraType::Ptr,
    }
}

fn shim_c_type(ty: &Type) -> &'static str {
    match ty.get_kind() {
        TypeKind::Bool => "int",
        TypeKind::CharS | TypeKind::SChar | TypeKind::CharU | TypeKind::UChar
        | TypeKind::Short | TypeKind::Int | TypeKind::Enum => "int32_t",
        TypeKind::UShort | TypeKind::UInt => "uint32_t",
        TypeKind::Long | TypeKind::LongLong => "int64_t",
        TypeKind::ULong | TypeKind::ULongLong => "uint64_t",
        TypeKind::Float => "float",
        TypeKind::Double | TypeKind::LongDouble => "double",
        TypeKind::Pointer => {
            let pointee = ty.get_pointee_type();
            if let Some(pt) = pointee {
                let pk = pt.get_kind();
                if pk == TypeKind::CharS || pk == TypeKind::SChar || pk == TypeKind::CharU {
                    return "const char *";
                }
            }
            "void *"
        }
        TypeKind::Typedef | TypeKind::Elaborated => shim_c_type(&ty.get_canonical_type()),
        _ => "void *",
    }
}

fn shim_c_return_type(ty: &Type) -> String {
    match ty.get_kind() {
        TypeKind::Void => "void".into(),
        TypeKind::Bool => "int".into(),
        TypeKind::CharS | TypeKind::SChar | TypeKind::CharU | TypeKind::UChar
        | TypeKind::Short | TypeKind::Int | TypeKind::Enum => "int32_t".into(),
        TypeKind::UShort | TypeKind::UInt => "uint32_t".into(),
        TypeKind::Long | TypeKind::LongLong => "int64_t".into(),
        TypeKind::ULong | TypeKind::ULongLong => "uint64_t".into(),
        TypeKind::Float => "float".into(),
        TypeKind::Double | TypeKind::LongDouble => "double".into(),
        TypeKind::Pointer => {
            let pointee = ty.get_pointee_type();
            if let Some(pt) = pointee {
                let pk = pt.get_kind();
                if pk == TypeKind::CharS || pk == TypeKind::SChar || pk == TypeKind::CharU {
                    return "const char *".into();
                }
            }
            "void *".into()
        }
        TypeKind::Typedef | TypeKind::Elaborated => shim_c_return_type(&ty.get_canonical_type()),
        _ => "void *".into(),
    }
}

fn cast_to_c(ty: &Type, var: &str) -> String {
    let c_ty = ty.get_display_name();
    match ty.get_kind() {
        TypeKind::Bool
        | TypeKind::CharS
        | TypeKind::SChar
        | TypeKind::CharU
        | TypeKind::UChar
        | TypeKind::Short
        | TypeKind::Int
        | TypeKind::UShort
        | TypeKind::UInt
        | TypeKind::Long
        | TypeKind::LongLong
        | TypeKind::ULong
        | TypeKind::ULongLong
        | TypeKind::Float
        | TypeKind::Double
        | TypeKind::LongDouble => var.to_string(),
        TypeKind::Pointer => {
            let pointee = ty.get_pointee_type();
            if let Some(pt) = pointee {
                let pk = pt.get_kind();
                if pk == TypeKind::CharS || pk == TypeKind::SChar || pk == TypeKind::CharU {
                    return var.to_string();
                }
            }
            format!("({c_ty}){var}")
        }
        TypeKind::Typedef | TypeKind::Elaborated => cast_to_c(&ty.get_canonical_type(), var),
        _ => format!("({c_ty}){var}"),
    }
}

fn cast_to_cxx(ty: &Type, var: &str) -> String {
    cast_to_c(ty, var)
}
