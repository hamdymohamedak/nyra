use std::collections::HashMap;
use std::collections::HashSet;
use std::path::PathBuf;
use std::process::Command;

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
    let mut args = if config.cxx {
        vec![
            "-std=c++17".to_string(),
            "-x".to_string(),
            "c++".to_string(),
            "-stdlib=libc++".to_string(),
        ]
    } else {
        vec!["-std=c11".to_string(), "-x".to_string(), "c".to_string()]
    };
    // On macOS C++: never put SDK usr/include on -I (it sorts before libc++ and
    // breaks wrapping headers). Use -isysroot + -isystem so libc++ comes first.
    if config.cxx {
        if let Some(sdk) = macos_sdk_path() {
            args.push("-isysroot".into());
            args.push(sdk.clone());
            for inc in cxx_stdlib_includes() {
                args.push("-isystem".into());
                args.push(inc.display().to_string());
            }
            args.push("-isystem".into());
            args.push(format!("{sdk}/usr/include"));
        } else {
            for inc in cxx_stdlib_includes() {
                args.push("-isystem".into());
                args.push(inc.display().to_string());
            }
        }
    }
    for inc in &config.includes {
        if config.cxx && (is_macos_sdk_usr_include(inc) || is_clang_resource_include(inc)) {
            continue;
        }
        args.push(format!("-I{}", inc.display()));
    }
    for def in &config.defines {
        args.push(format!("-D{def}"));
    }
    for fi in &config.force_includes {
        args.push("-include".into());
        args.push(fi.clone());
    }

    let tu = index
        .parser(&config.header)
        .arguments(&args.iter().map(String::as_str).collect::<Vec<_>>())
        .parse()
        .map_err(|e| format!("libclang parse failed: {e}"))?;

    for diag in tu.get_diagnostics() {
        if diag.get_severity() as i32 >= 3 {
            let mut msg = format!("clang diagnostic: {}", diag.get_text());
            if std::env::var_os("NYRA_BIND_DEBUG").is_some() {
                msg.push_str("\n  clang args:");
                for a in &args {
                    msg.push_str(&format!("\n    {a}"));
                }
            }
            return Err(msg);
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

fn macos_sdk_path() -> Option<String> {
    let out = Command::new("xcrun").args(["--show-sdk-path"]).output().ok()?;
    if !out.status.success() {
        return None;
    }
    let sdk = String::from_utf8_lossy(&out.stdout).trim().to_string();
    if sdk.is_empty() {
        None
    } else {
        Some(sdk)
    }
}

fn is_macos_sdk_usr_include(path: &PathBuf) -> bool {
    let s = path.to_string_lossy();
    s.contains(".sdk/usr/include") || s.ends_with("MacOSX.sdk/usr/include")
}

fn is_clang_resource_include(path: &PathBuf) -> bool {
    let s = path.to_string_lossy().replace('\\', "/");
    s.contains("/lib/clang/") && s.ends_with("/include")
}

fn cxx_stdlib_includes() -> Vec<PathBuf> {
    let mut paths = Vec::new();
    // Prefer a single libc++ tree — mixing Homebrew LLVM with Apple CLT headers
    // breaks symbols like std::__hash_memory and wrapping <math.h>.
    if let Ok(out) = Command::new("brew").args(["--prefix", "llvm"]).output() {
        if out.status.success() {
            let llvm = String::from_utf8_lossy(&out.stdout).trim().to_string();
            if !llvm.is_empty() {
                let root = PathBuf::from(&llvm);
                let v1 = root.join("include/c++/v1");
                if v1.is_dir() {
                    paths.push(v1);
                    // Clang resource dir supplies builtins; keep after libc++.
                    let clang_dir = root.join("lib/clang");
                    if let Ok(entries) = std::fs::read_dir(&clang_dir) {
                        let mut vers: Vec<_> = entries.filter_map(|e| e.ok()).collect();
                        vers.sort_by_key(|e| e.file_name());
                        if let Some(last) = vers.last() {
                            let res = last.path().join("include");
                            if res.is_dir() {
                                paths.push(res);
                            }
                        }
                    }
                    return paths;
                }
            }
        }
    }
    for cand in [
        "/Library/Developer/CommandLineTools/usr/include/c++/v1",
        "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include/c++/v1",
    ] {
        let p = PathBuf::from(cand);
        if p.is_dir() && !paths.iter().any(|x| x == &p) {
            paths.push(p);
        }
    }
    paths
}

fn collect_types(entity: &Entity, ctx: &mut TypeContext) {
    // sodium.h (and friends) pull in libc headers; never emit their records into `.ny`.
    if entity_from_system_path(entity) {
        return;
    }
    match entity.get_kind() {
        EntityKind::StructDecl | EntityKind::UnionDecl => {
            if let Some(raw) = entity.get_name().filter(|n| !n.is_empty()) {
                if let Some(name) = usable_record_name(&raw) {
                    if let Some(st) = parse_struct(entity, &name, ctx) {
                        ctx.structs.insert(name, st);
                    }
                }
            }
        }
        EntityKind::TypedefDecl => {
            if let Some(raw) = entity.get_name() {
                if let Some(name) = usable_record_name(&raw) {
                    if let Some(underlying) = entity.get_typedef_underlying_type() {
                        if underlying.get_kind() == TypeKind::Record {
                            if let Some(decl) = underlying.get_declaration() {
                                if entity_from_system_path(&decl) {
                                    // typedef in user header of a system record — still skip the record body
                                } else if let Some(st) = parse_struct(&decl, &name, ctx) {
                                    ctx.structs.insert(name, st);
                                }
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

fn entity_from_system_path(entity: &Entity) -> bool {
    if entity.is_in_system_header() {
        return true;
    }
    let path = entity
        .get_location()
        .and_then(|loc| loc.get_file_location().file)
        .map(|f| f.get_path())
        .unwrap_or_default();
    let p = path.to_string_lossy();
    p.contains("/usr/include")
        || p.contains("/usr/lib")
        || p.contains("MacOSX.sdk")
        || p.contains("iPhoneOS.sdk")
        || p.contains("/Xcode.app/")
        || p.contains("\\Windows Kits\\")
        || p.contains("/linux/")
}

/// Accept only identifiers Nyra can parse as a struct name (no clang "unnamed at …").
fn usable_record_name(raw: &str) -> Option<String> {
    let stripped = sanitize_type_name(raw);
    if stripped.is_empty()
        || stripped.contains("unnamed")
        || stripped.contains('(')
        || stripped.contains(' ')
        || stripped.contains('/')
        || stripped.contains(':')
    {
        return None;
    }
    let name = names::sanitize_identifier(&stripped);
    let mut chars = name.chars();
    match chars.next() {
        Some(c) if c == '_' || c.is_ascii_alphabetic() => {}
        _ => return None,
    }
    if !chars.all(|c| c.is_ascii_alphanumeric() || c == '_') {
        return None;
    }
    Some(name)
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
    visit_functions_inner(entity, config, ctx, spec, &mut HashSet::new());
}

fn visit_functions_inner(
    entity: &Entity,
    config: &BindConfig,
    ctx: &TypeContext,
    spec: &mut BindSpec,
    seen: &mut HashSet<String>,
) {
    const CXX_SHIM_CAP: usize = 256;

    if entity_from_system_path(entity) {
        return;
    }

    if entity.get_kind() == EntityKind::FunctionDecl {
        if let Some(name) = entity.get_name() {
            if config.matches_export(&name) && !name.starts_with("operator") {
                match map_function(entity, &name, ctx) {
                    Ok(f) => {
                        if config.cxx {
                            if let Some(shim) = crate::shim::try_cxx_extern_c_function(entity, &name)
                            {
                                if seen.insert(shim.nyra_name.clone())
                                    && spec.shims.len() < CXX_SHIM_CAP
                                {
                                    spec.functions.push(CFunction {
                                        name: shim.nyra_name.clone(),
                                        params: shim.nyra_params.clone(),
                                        return_type: shim.nyra_return.clone(),
                                    });
                                    spec.shims.push(shim);
                                }
                            } else if crate::shim::has_c_linkage(entity) {
                                if seen.insert(f.name.clone()) {
                                    spec.functions.push(f);
                                }
                            } else if seen.insert(f.name.clone()) {
                                // Unwrappable C++ symbol — still emit direct bind (may need manual shim).
                                spec.functions.push(f);
                            }
                        } else if seen.insert(f.name.clone()) {
                            spec.functions.push(f);
                        }
                    }
                    Err(reason) => {
                        if config.cxx {
                            // C-style shims misuse C++ display types (string_view, refs, …).
                            spec.skipped.push(format!("{name}: {reason}"));
                        } else if config.generate_shims {
                            if let Some(shim) = crate::shim::try_shim_function(entity, &name) {
                                if seen.insert(shim.nyra_name.clone()) {
                                    spec.shims.push(shim.clone());
                                    spec.functions.push(CFunction {
                                        name: shim.nyra_name.clone(),
                                        params: shim.nyra_params.clone(),
                                        return_type: shim.nyra_return.clone(),
                                    });
                                }
                            } else {
                                spec.skipped.push(format!("{name}: {reason}"));
                            }
                        } else {
                            spec.skipped.push(format!("{name}: {reason}"));
                        }
                    }
                }
            }
        }
    }

    if config.cxx && entity.get_kind() == EntityKind::Method && spec.shims.len() < CXX_SHIM_CAP {
        if let Some(shim) = crate::shim::try_cxx_extern_c_method(entity) {
            if config.matches_export(&shim.nyra_name) && seen.insert(shim.nyra_name.clone()) {
                spec.functions.push(CFunction {
                    name: shim.nyra_name.clone(),
                    params: shim.nyra_params.clone(),
                    return_type: shim.nyra_return.clone(),
                });
                spec.shims.push(shim);
            }
        }
    }

    for child in entity.get_children() {
        visit_functions_inner(&child, config, ctx, spec, seen);
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
        // C `float` is IEEE-754 binary32 — must stay `f32` for ABI (raylib Vector2, etc.).
        TypeKind::Float => Ok(NyraType::F32),
        TypeKind::Double | TypeKind::LongDouble => Ok(NyraType::F64),
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
            return usable_record_name(&name).ok_or_else(|| "anonymous struct".into());
        }
        if let Some(display) = decl.get_display_name() {
            if !display.is_empty() && display != "unnamed" {
                return usable_record_name(&display).ok_or_else(|| "anonymous struct".into());
            }
        }
    }
    let display = ty.get_display_name();
    if display.is_empty() {
        Err("anonymous struct".into())
    } else {
        usable_record_name(&display).ok_or_else(|| "anonymous struct".into())
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

    #[test]
    fn rejects_clang_unnamed_records() {
        assert!(usable_record_name(
            "struct (unnamed at /Applications/Xcode.app/Contents/Developer/SDKs/MacOSX.sdk/usr/include/sys/wait.h:199:2)"
        )
        .is_none());
        assert_eq!(usable_record_name("Point").as_deref(), Some("Point"));
    }
}
