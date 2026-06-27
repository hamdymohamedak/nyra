//! `Future<T>` type mapping for async v2.

use ast::TypeAnnotation;
use types::Type;

pub fn future_struct_from_ann(ann: &TypeAnnotation) -> Option<String> {
    match ann {
        TypeAnnotation::Integer(_) => Some("Future_i32".into()),
        TypeAnnotation::Bool => Some("Future_bool".into()),
        TypeAnnotation::String => Some("Future_string".into()),
        TypeAnnotation::Struct(name) if name.starts_with("Future_") => Some(name.clone()),
        TypeAnnotation::Applied { base, args } if base == "Future" && args.len() == 1 => {
            future_struct_from_ann(&args[0])
        }
        _ => None,
    }
}

pub fn future_await_result_type(ty: &Type) -> Option<Type> {
    match ty {
        Type::Struct(name) => match name.as_str() {
            "Future_i32" => Some(Type::Integer(ast::IntKind::I32)),
            "Future_bool" => Some(Type::Bool),
            "Future_string" => Some(Type::String),
            _ => None,
        },
        _ => None,
    }
}

pub fn is_future_handle_type(ty: &Type) -> bool {
    matches!(ty, Type::Struct(name) if name.starts_with("Future_"))
        || matches!(ty, Type::Handle)
        || types::is_integer(ty)
}
