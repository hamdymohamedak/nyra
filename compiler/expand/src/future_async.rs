//! Map async return types to `Future_*` wrappers and typed promise completion.

use ast::*;
use errors::Span;
use std::collections::HashMap;
use types::Type;

pub fn future_struct_name_from_ann(ret: &TypeAnnotation) -> Option<&'static str> {
    match ret {
        TypeAnnotation::Integer(_) => Some("Future_i32"),
        TypeAnnotation::Bool => Some("Future_bool"),
        TypeAnnotation::String => Some("Future_string"),
        TypeAnnotation::Struct(name) if name.starts_with("Future_") => None,
        TypeAnnotation::Applied { base, args } if base == "Future" && args.len() == 1 => {
            future_struct_name_from_ann(&args[0])
        }
        _ => None,
    }
}

pub fn future_complete_callee(ret: &TypeAnnotation) -> &'static str {
    match ret {
        TypeAnnotation::Bool => "async_promise_complete_bool",
        TypeAnnotation::String => "async_promise_complete_ptr",
        _ => "async_promise_complete",
    }
}

/// Cooperative poll strategy for state-machine `await` desugar.
#[derive(Clone, Copy, Debug, PartialEq, Eq)]
pub enum PollKind {
    I32,
    Bool,
    String,
}

pub fn poll_kind_for_future_struct(name: &str) -> PollKind {
    match name {
        "Future_bool" => PollKind::Bool,
        "Future_string" => PollKind::String,
        _ => PollKind::I32,
    }
}

pub fn poll_kind_for_return_ann(ann: &TypeAnnotation) -> PollKind {
    match ann {
        TypeAnnotation::Bool => PollKind::Bool,
        TypeAnnotation::String => PollKind::String,
        _ => PollKind::I32,
    }
}

/// Cooperative poll callee for `async_poll` / `async_poll_bool` state-machine loops.
pub fn future_poll_callee(future_struct: &str) -> &'static str {
    match future_struct {
        "Future_bool" => "async_poll_bool",
        _ => "async_poll",
    }
}

fn expr_field(object: Expression, field: &str, span: Span) -> Expression {
    Expression::FieldAccess(Box::new(FieldAccessExpr {
        object,
        field: field.into(),
        optional: false,
        span: span.clone(),
    }))
}

fn future_struct_name_from_expr(
    expr: &Expression,
    checker: &typecheck::TypeChecker,
    locals: &HashMap<String, Type>,
) -> Option<String> {
    if let Expression::Variable { name, .. } = expr {
        if let Some(Type::Struct(n)) = locals.get(name) {
            if n.starts_with("Future_") {
                return Some(n.clone());
            }
        }
    }
    if let Some(Type::Struct(n)) = checker.expression_type_hint(expr) {
        if n.starts_with("Future_") {
            return Some(n);
        }
    }
    if let Expression::Call(c) = expr {
        if let Some(sig) = checker.env.functions.get(&c.callee) {
            if let Type::Struct(n) = &sig.return_type {
                if n.starts_with("Future_") {
                    return Some(n.clone());
                }
            }
        }
    }
    None
}

/// Extract the promise handle from a `Future_*` expression, or pass through raw handles.
pub fn await_handle_expr(
    inner: &Expression,
    checker: &typecheck::TypeChecker,
    locals: &HashMap<String, Type>,
    span: Span,
) -> Expression {
    if let Expression::Call(c) = inner {
        if c.callee.starts_with("Future_from_handle_") && c.args.len() == 1 {
            return c.args[0].clone();
        }
    }
    if future_struct_name_from_expr(inner, checker, locals).is_some() {
        return expr_field(inner.clone(), "handle", span);
    }
    inner.clone()
}

/// Pick poll runtime for an awaited expression (after typecheck).
pub fn poll_kind_for_expr(
    inner: &Expression,
    checker: &typecheck::TypeChecker,
    locals: &HashMap<String, Type>,
) -> PollKind {
    future_struct_name_from_expr(inner, checker, locals)
        .map(|n| poll_kind_for_future_struct(&n))
        .unwrap_or(PollKind::I32)
}

pub fn infer_let_binding_type(
    value: &Expression,
    checker: &typecheck::TypeChecker,
    locals: &HashMap<String, Type>,
) -> Option<Type> {
    if let Expression::Variable { name, .. } = value {
        if let Some(ty) = locals.get(name) {
            return Some(ty.clone());
        }
    }
    checker.expression_type_hint(value)
}

pub fn bind_let_type(
    name: &str,
    value: &Expression,
    checker: &typecheck::TypeChecker,
    locals: &mut HashMap<String, Type>,
) {
    if let Some(ty) = infer_let_binding_type(value, checker, locals) {
        locals.insert(name.to_string(), ty);
    }
}

/// Default value for `__nyra_await_result` before the first `await` completes.
pub fn await_result_zero_expr(kind: PollKind, span: Span) -> Expression {
    match kind {
        PollKind::String => Expression::Literal(Literal::String(String::new())),
        PollKind::Bool => Expression::Literal(Literal::Bool(false)),
        PollKind::I32 => Expression::Literal(Literal::Int(0)),
    }
}

pub fn poll_callee_for_expr(
    inner: &Expression,
    checker: &typecheck::TypeChecker,
    locals: &HashMap<String, Type>,
) -> &'static str {
    match poll_kind_for_expr(inner, checker, locals) {
        PollKind::Bool => "async_poll_bool",
        PollKind::String => "async_future_done",
        PollKind::I32 => "async_poll",
    }
}

pub fn future_struct_literal(handle: &str, struct_name: &str, span: Span) -> Expression {
    Expression::StructLiteral(StructLiteralExpr {
        name: struct_name.into(),
        fields: vec![(
            "handle".into(),
            Expression::Variable {
                name: handle.into(),
                span: span.clone(),
            },
        )],
        spreads: vec![],
        span,
    })
}

fn looks_desugared_async(func: &Function) -> bool {
    func.body.statements.iter().any(|s| {
        matches!(s, Statement::Let(l) if l.name.starts_with("__nyra_async_h_"))
    })
}

pub fn patch_desugared_async_returns(program: &mut Program) {
    for f in &mut program.functions {
        patch_one_desugared_async_return(f);
    }
    for imp in &mut program.impls {
        for m in &mut imp.methods {
            patch_one_desugared_async_return(m);
        }
    }
    for ti in &mut program.trait_impls {
        for m in &mut ti.methods {
            patch_one_desugared_async_return(m);
        }
    }
}

fn patch_one_desugared_async_return(func: &mut Function) {
    if func.exported || !looks_desugared_async(func) {
        return;
    }
    if let Some(ann) = &func.return_type {
        if let Some(name) = future_struct_name_from_ann(ann) {
            func.return_type = Some(TypeAnnotation::Struct(name.to_string()));
            return;
        }
    }
    func.return_type = Some(TypeAnnotation::Struct("Future_i32".into()));
}
