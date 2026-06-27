use std::collections::HashMap;

use clang::{Clang, Entity, EntityKind, Index, Type, TypeKind};

use crate::config::BindConfig;
use crate::names;
use crate::shim::CShimFn;
use crate::types::NyraType;

#[derive(Debug, Clone)]
pub struct CFunction {
    pub name: String,
    pub params: Vec<(String, NyraType)>,
    pub return_type: NyraType,
}

#[derive(Debug, Clone)]
pub struct CStruct {
    pub name: String,
    pub fields: Vec<(String, NyraType)>,
}

#[derive(Debug, Default)]
pub struct BindSpec {
    pub functions: Vec<CFunction>,
    pub structs: Vec<CStruct>,
    pub shims: Vec<CShimFn>,
    pub skipped: Vec<String>,
}

struct TypeContext {
    structs: HashMap<String, CStruct>,
}

pub fn parse_header(config: &BindConfig) -> Result<BindSpec, String> {
    if !config.header.is_file() {
        return Err(format!("header not found: {}", config.header.display()));
    }

    let clang = Clang::new().map_err(|e| format!("libclang not available: {e}"))?;
    let index = Index::new(&clang, false, false);
    let mut args = vec!["-std=c11".to_string(), "-x".to_string(), "c".to_string()];
    for inc in &config.includes {
        args.push(format!("-I{}", inc.display()));
    }
    for def in &config.defines {
        args.push(format!("-D{def}"));
    }

    let tu = index
        .parser(&config.header)
        .arguments(&args.iter().map(String::as_str).collect::<Vec<_>>())
        .parse()
        .map_err(|e| format!("libclang parse failed: {e}"))?;

    for diag in tu.get_diagnostics() {
        if diag.get_severity() as i32 >= 3 {
            return Err(format!("clang diagnostic: {}", diag.get_text()));
        }
    }

    let mut ctx = TypeContext {
        structs: HashMap::new(),
    };
    collect_types(&tu.get_entity(), &mut ctx);

    let mut spec = BindSpec {
        structs: ctx.structs.values().cloned().collect(),
        ..Default::default()
    };
    spec.structs.sort_by(|a, b| a.name.cmp(&b.name));

    visit_functions(&tu.get_entity(), config, &ctx, &mut spec);

    if spec.functions.is_empty() {
        return Err(format!(
            "no bindable functions in {} (skipped {} symbols)",
            config.header.display(),
            spec.skipped.len()
        ));
    }
    Ok(spec)
}

fn collect_types(entity: &Entity, ctx: &mut TypeContext) {
    match entity.get_kind() {
        EntityKind::StructDecl | EntityKind::UnionDecl => {
            if let Some(name) = entity.get_name().filter(|n| !n.is_empty()) {
                if let Some(st) = parse_struct(entity, &name, ctx) {
                    ctx.structs.insert(name, st);
                }
            }
        }
        EntityKind::TypedefDecl => {
            if let Some(name) = entity.get_name() {
                if let Some(underlying) = entity.get_typedef_underlying_type() {
                    if underlying.get_kind() == TypeKind::Record {
                        if let Some(decl) = underlying.get_declaration() {
                            if let Some(st) = parse_struct(&decl, &name, ctx) {
                                ctx.structs.insert(name, st);
                            }
                        }
                    }
                }
            }
        }
        _ => {}
    }
    for child in entity.get_children() {
        collect_types(&child, ctx);
    }
}

fn parse_struct(entity: &Entity, name: &str, ctx: &TypeContext) -> Option<CStruct> {
    if entity.get_kind() == EntityKind::UnionDecl {
        return None;
    }
    let mut fields = Vec::new();
    for child in entity.get_children() {
        if child.get_kind() != EntityKind::FieldDecl {
            continue;
        }
        let fname = child.get_name().unwrap_or_else(|| "field".into());
        let fty = child.get_type()?;
        match map_field_type(&fty, ctx) {
            Ok(ny) => fields.push((names::sanitize_identifier(&fname), ny)),
            Err(_) => return None,
        }
    }
    if fields.is_empty() {
        return None;
    }
    Some(CStruct {
        name: name.to_string(),
        fields,
    })
}

fn visit_functions(entity: &Entity, config: &BindConfig, ctx: &TypeContext, spec: &mut BindSpec) {
    if entity.get_kind() == EntityKind::FunctionDecl {
        if let Some(name) = entity.get_name() {
            if entity.is_in_system_header() {
                return;
            }
            if !config.matches_export(&name) {
                return;
            }
            match map_function(entity, &name, ctx) {
                Ok(f) => spec.functions.push(f),
                Err(reason) => {
                    if config.generate_shims {
                        if let Some(shim) = crate::shim::try_shim_function(entity, &name) {
                            spec.shims.push(shim.clone());
                            spec.functions.push(CFunction {
                                name: shim.nyra_name.clone(),
                                params: shim.nyra_params.clone(),
                                return_type: shim.nyra_return.clone(),
                            });
                            return;
                        }
                    }
                    spec.skipped.push(format!("{name}: {reason}"));
                }
            }
        }
    }
    for child in entity.get_children() {
        visit_functions(&child, config, ctx, spec);
    }
}

fn map_function(entity: &Entity, name: &str, ctx: &TypeContext) -> Result<CFunction, String> {
    let ret_ty = entity.get_result_type().ok_or("missing return type")?;
    let return_type = map_type(&ret_ty, false, ctx)?;

    let mut params = Vec::new();
    if let Some(args) = entity.get_arguments() {
        for (i, arg) in args.into_iter().enumerate() {
            let arg_ty = arg
                .get_type()
                .ok_or_else(|| format!("param {i} missing type"))?;
            let ny_ty = map_type(&arg_ty, true, ctx)?;
            let pname = arg
                .get_name()
                .filter(|n| !n.is_empty())
                .unwrap_or_else(|| format!("arg{i}"));
            params.push((names::sanitize_identifier(&pname), ny_ty));
        }
    }

    Ok(CFunction {
        name: name.to_string(),
        params,
        return_type,
    })
}

fn map_field_type(ty: &Type, ctx: &TypeContext) -> Result<NyraType, String> {
    map_type(ty, false, ctx)
}

fn map_type(ty: &Type, is_param: bool, ctx: &TypeContext) -> Result<NyraType, String> {
    let kind = ty.get_kind();
    match kind {
        TypeKind::Void => Ok(NyraType::Void),
        TypeKind::Bool => Ok(NyraType::Bool),
        TypeKind::CharS | TypeKind::SChar => Ok(NyraType::Int("i8")),
        TypeKind::CharU | TypeKind::UChar => Ok(NyraType::Int("u8")),
        TypeKind::Short => Ok(NyraType::Int("i16")),
        TypeKind::UShort => Ok(NyraType::Int("u16")),
        TypeKind::Int => Ok(NyraType::Int("i32")),
        TypeKind::UInt => Ok(NyraType::Int("u32")),
        TypeKind::Long => Ok(NyraType::Int("i64")),
        TypeKind::ULong => Ok(NyraType::Int("u64")),
        TypeKind::LongLong => Ok(NyraType::Int("i64")),
        TypeKind::ULongLong => Ok(NyraType::Int("u64")),
        TypeKind::Float | TypeKind::Double | TypeKind::LongDouble => Ok(NyraType::F64),
        TypeKind::Pointer => {
            let pointee = ty.get_pointee_type().ok_or("pointer without pointee")?;
            let pk = pointee.get_kind();
            if pk == TypeKind::CharS || pk == TypeKind::SChar || pk == TypeKind::CharU {
                Ok(NyraType::String)
            } else if pk == TypeKind::Record {
                Ok(NyraType::Ptr)
            } else {
                Ok(NyraType::Ptr)
            }
        }
        TypeKind::ConstantArray | TypeKind::IncompleteArray => {
            if is_param {
                Ok(NyraType::Ptr)
            } else {
                Err(format!("array type {kind:?}"))
            }
        }
        TypeKind::Typedef | TypeKind::Elaborated => {
            let canonical = ty.get_canonical_type();
            map_type(&canonical, is_param, ctx)
        }
        TypeKind::Record => {
            let name = record_name(ty)?;
            if ctx.structs.contains_key(&name) {
                Ok(NyraType::Struct(name))
            } else if is_param {
                Ok(NyraType::Ptr)
            } else {
                Err(format!("unknown struct `{name}` by value"))
            }
        }
        TypeKind::Enum => Ok(NyraType::Int("i32")),
        TypeKind::FunctionPrototype | TypeKind::FunctionNoPrototype => Ok(NyraType::Ptr),
        other => Err(format!("unsupported C type {other:?}")),
    }
}

fn record_name(ty: &Type) -> Result<String, String> {
    if let Some(decl) = ty.get_declaration() {
        if let Some(name) = decl.get_name().filter(|n| !n.is_empty()) {
            return Ok(name);
        }
        if let Some(display) = decl.get_display_name() {
            if !display.is_empty() && display != "unnamed" {
                return Ok(sanitize_type_name(&display));
            }
        }
    }
    let display = ty.get_display_name();
    if display.is_empty() {
        Err("anonymous struct".into())
    } else {
        Ok(sanitize_type_name(&display))
    }
}

fn sanitize_type_name(name: &str) -> String {
    name.trim_start_matches("struct ")
        .trim_start_matches("union ")
        .trim_start_matches("enum ")
        .to_string()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sanitize_strips_struct_prefix() {
        assert_eq!(sanitize_type_name("struct Point"), "Point");
    }
}
