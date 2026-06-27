use ast::{IntKind, TypeAnnotation};

use crate::Type;

pub fn is_integer(ty: &Type) -> bool {
    matches!(ty, Type::Integer(_))
}

pub fn is_integer_ann(ann: &TypeAnnotation) -> bool {
    matches!(ann, TypeAnnotation::Integer(_))
}

pub fn int_kind_of(ty: &Type) -> Option<IntKind> {
    match ty {
        Type::Integer(k) => Some(*k),
        _ => None,
    }
}

pub fn int_kind_of_ann(ann: &TypeAnnotation) -> Option<IntKind> {
    match ann {
        TypeAnnotation::Integer(k) => Some(*k),
        _ => None,
    }
}

pub fn type_from_int_kind(k: IntKind) -> Type {
    Type::Integer(k)
}

pub fn ann_from_int_kind(k: IntKind) -> TypeAnnotation {
    TypeAnnotation::Integer(k)
}

pub fn unify_integer_types(left: Type, right: Type) -> Type {
    match (int_kind_of(&left), int_kind_of(&right)) {
        (Some(a), Some(b)) => Type::Integer(IntKind::unify(a, b)),
        (Some(a), None) | (None, Some(a)) => Type::Integer(a),
        _ => Type::Integer(IntKind::I32),
    }
}

pub fn is_numeric(ty: &Type) -> bool {
    matches!(ty, Type::Integer(_) | Type::F32 | Type::F64 | Type::Unknown)
}

pub fn unify_numeric(left: Type, right: Type) -> Type {
    if left == Type::F64 || right == Type::F64 {
        Type::F64
    } else if left == Type::F32 || right == Type::F32 {
        Type::F32
    } else if is_integer(&left) || is_integer(&right) {
        unify_integer_types(left, right)
    } else {
        Type::Integer(IntKind::I32)
    }
}

/// `let x: u8 = 255` — integer literals (inferred as `i32`) may bind to any integer type.
pub fn integer_assignable(declared: &Type, value: &Type) -> bool {
    int_kind_of(declared).is_some() && int_kind_of(value).is_some()
}

/// Extract the numeric value from an integer literal expression, if any.
pub fn int_literal_value(expr: &ast::Expression) -> Option<i64> {
    match expr {
        ast::Expression::Literal(ast::Literal::Int(n)) => Some(*n),
        ast::Expression::Literal(ast::Literal::IntKind(n, _)) => Some(*n),
        ast::Expression::Unary(u) if u.op == ast::UnaryOp::Neg => {
            int_literal_value(&u.operand).map(|n| -n)
        }
        _ => None,
    }
}

/// True when `n` fits the declared integer type (for `let x: u8 = 255` style bindings).
pub fn integer_literal_fits(declared: &Type, n: i64) -> bool {
    int_kind_of(declared)
        .map(|k| k.literal_fits_i64(n))
        .unwrap_or(true)
}

pub fn int_display(k: IntKind) -> &'static str {
    k.name()
}

pub fn int_llvm(k: IntKind) -> &'static str {
    k.llvm_name()
}
