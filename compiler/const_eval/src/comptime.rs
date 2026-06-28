//! Compile-time evaluation for `comptime` modules and `#[comptime]` functions.

use std::collections::HashMap;

use ast::{Block, Expression, ForKind, Function, Program, Statement, UnaryOp};
use errors::{ErrorKind, NyraError, Span};

use crate::{const_value_to_expr, eval_const_expr, ConstValue};

const MAX_COMPTIME_STEPS: usize = 65_536;
const MAX_COMPTIME_DEPTH: usize = 256;

pub fn finalize_comptime_module(program: &mut Program) -> Vec<NyraError> {
    if !program.comptime {
        return vec![];
    }
    let mut errors = validate_comptime_module(program);
    if !errors.is_empty() {
        return errors;
    }
    let functions: HashMap<String, Function> = program
        .functions
        .iter()
        .map(|f| (f.name.clone(), f.clone()))
        .collect();
    let mut env = HashMap::new();
    for c in &mut program.consts {
        match eval_comptime_expr(&c.value, &env, &functions, 0) {
            Ok(v) => {
                env.insert(c.name.clone(), v.clone());
                c.value = const_value_to_expr(&v);
            }
            Err(e) => errors.push(e),
        }
    }
    if errors.is_empty() {
        strip_comptime_artifacts(program);
    }
    errors
}

pub fn strip_comptime_artifacts(program: &mut Program) {
    program.functions.clear();
    program.externs.clear();
    program.impls.clear();
    program.trait_impls.clear();
    program.macros.clear();
    program.export_instances.clear();
}

fn validate_comptime_module(program: &Program) -> Vec<NyraError> {
    let mut errors = Vec::new();
    if !program.externs.is_empty() {
        errors.push(comptime_error(
            Span::default(),
            "comptime modules cannot declare `extern` functions",
        ));
    }
    for f in &program.functions {
        if f.name == "main" {
            errors.push(comptime_error(
                f.span.clone(),
                "comptime modules cannot define `main`",
            )
            .help("use a regular `.ny` entry file and `import` this comptime module"));
        }
        if f.is_async {
            errors.push(comptime_error(
                f.span.clone(),
                format!("comptime function `{}` cannot be `async`", f.name),
            ));
        }
        if f.is_test {
            errors.push(comptime_error(
                f.span.clone(),
                format!("comptime function `{}` cannot be a `test`", f.name),
            ));
        }
        if f.exported {
            errors.push(comptime_error(
                f.span.clone(),
                format!("comptime function `{}` cannot be `export fn`", f.name),
            )
            .help("export `pub const` values from comptime modules instead"));
        }
        walk_block_forbidden(&f.body, &f.name, &mut errors);
    }
    errors
}

fn comptime_error(span: Span, message: impl Into<String>) -> NyraError {
    NyraError::new(ErrorKind::ConstEval, span, message)
}

fn walk_block_forbidden(block: &Block, fn_name: &str, errors: &mut Vec<NyraError>) {
    for stmt in &block.statements {
        walk_stmt_forbidden(stmt, fn_name, errors);
    }
}

fn walk_stmt_forbidden(stmt: &Statement, fn_name: &str, errors: &mut Vec<NyraError>) {
    match stmt {
        Statement::Print(p) => {
            errors.push(comptime_error(
                p.args.first().map(expr_span).unwrap_or_default(),
                format!("comptime function `{fn_name}` cannot use `print`"),
            ));
        }
        Statement::Spawn(b) => {
            errors.push(comptime_error(
                b.statements
                    .first()
                    .map(stmt_span)
                    .unwrap_or_default(),
                format!("comptime function `{fn_name}` cannot use `spawn`"),
            ));
        }
        Statement::Defer(e) => {
            errors.push(comptime_error(
                expr_span(e),
                format!("comptime function `{fn_name}` cannot use `defer`"),
            ));
        }
        Statement::Unsafe(b) => {
            errors.push(comptime_error(
                b.statements
                    .first()
                    .map(stmt_span)
                    .unwrap_or_default(),
                format!("comptime function `{fn_name}` cannot use `unsafe`"),
            ));
        }
        Statement::Asm { span, .. } => {
            errors.push(comptime_error(
                span.clone(),
                format!("comptime function `{fn_name}` cannot use inline `asm`"),
            ));
        }
        Statement::Benchmark(b) => walk_block_forbidden(b, fn_name, errors),
        Statement::If(i) => {
            walk_block_forbidden(&i.then_block, fn_name, errors);
            if let Some(el) = &i.else_block {
                walk_block_forbidden(el, fn_name, errors);
            }
        }
        Statement::While(w) => walk_block_forbidden(&w.body, fn_name, errors),
        Statement::For(f) => {
            if f.parallel.is_some() {
                errors.push(comptime_error(
                    stmt_span(stmt),
                    format!("comptime function `{fn_name}` cannot use `parallel for`"),
                ));
            }
            walk_block_forbidden(&f.body, fn_name, errors);
        }
        _ => {}
    }
}

fn stmt_span(stmt: &Statement) -> Span {
    ast::stmt_span(stmt)
}

fn expr_span(expr: &Expression) -> Span {
    ast::expr_span(expr)
}

fn eval_comptime_expr(
    expr: &Expression,
    env: &HashMap<String, ConstValue>,
    functions: &HashMap<String, Function>,
    depth: usize,
) -> Result<ConstValue, NyraError> {
    if depth > MAX_COMPTIME_DEPTH {
        return Err(comptime_error(
            expr_span(expr),
            "comptime evaluation exceeded maximum call depth",
        ));
    }
    if let Some(v) = eval_const_expr(expr, env) {
        return Ok(v);
    }
    match expr {
        Expression::Variable { name, span } => env.get(name).cloned().ok_or_else(|| {
            comptime_error(span.clone(), format!("unknown comptime variable `{name}`"))
        }),
        Expression::Binary(b) => {
            let l = eval_comptime_expr(&b.left, env, functions, depth)?;
            let r = eval_comptime_expr(&b.right, env, functions, depth)?;
            apply_binary(b.op, l, r).ok_or_else(|| {
                comptime_error(
                    b.span.clone(),
                    "invalid comptime binary operation",
                )
            })
        }
        Expression::Unary(u) => {
            let v = eval_comptime_expr(&u.operand, env, functions, depth)?;
            apply_unary(u.op, v).ok_or_else(|| {
                comptime_error(u.span.clone(), "invalid comptime unary operation")
            })
        }
        Expression::Call(c) => {
            if !c.type_args.is_empty() {
                return Err(comptime_error(
                    c.span.clone(),
                    "generic calls are not supported in comptime evaluation yet",
                ));
            }
            let f = functions.get(&c.callee).ok_or_else(|| {
                comptime_error(
                    c.span.clone(),
                    format!("unknown comptime function `{}`", c.callee),
                )
            })?;
            let mut args = Vec::with_capacity(c.args.len());
            for arg in &c.args {
                args.push(eval_comptime_expr(arg, env, functions, depth)?);
            }
            eval_comptime_function(f, &args, functions, depth + 1)
        }
        Expression::If(i) => {
            let cond = eval_comptime_expr(&i.condition, env, functions, depth)?;
            match cond {
                ConstValue::Bool(true) => {
                    eval_comptime_expr(&i.then_expr, env, functions, depth)
                }
                ConstValue::Bool(false) => {
                    eval_comptime_expr(&i.else_expr, env, functions, depth)
                }
                _ => Err(comptime_error(
                    i.span.clone(),
                    "comptime if condition must be bool",
                )),
            }
        }
        Expression::Grouped(inner) => eval_comptime_expr(inner, env, functions, depth),
        other => Err(comptime_error(
            expr_span(other),
            "expression is not evaluable at comptime",
        )
        .help("comptime supports integers, bools, pure function calls, and `if` expressions")),
    }
}

fn apply_binary(op: ast::BinaryOp, l: ConstValue, r: ConstValue) -> Option<ConstValue> {
    use ast::BinaryOp;
    match (op, l, r) {
        (BinaryOp::Add, ConstValue::Int(a), ConstValue::Int(b)) => {
            Some(ConstValue::Int(a.saturating_add(b)))
        }
        (BinaryOp::Sub, ConstValue::Int(a), ConstValue::Int(b)) => {
            Some(ConstValue::Int(a.saturating_sub(b)))
        }
        (BinaryOp::Mul, ConstValue::Int(a), ConstValue::Int(b)) => {
            Some(ConstValue::Int(a.saturating_mul(b)))
        }
        (BinaryOp::Div, ConstValue::Int(a), ConstValue::Int(b)) if b != 0 => {
            Some(ConstValue::Int(a / b))
        }
        (BinaryOp::Mod, ConstValue::Int(a), ConstValue::Int(b)) if b != 0 => {
            Some(ConstValue::Int(a % b))
        }
        (BinaryOp::Eq, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Bool(a == b)),
        (BinaryOp::Ne, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Bool(a != b)),
        (BinaryOp::Lt, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Bool(a < b)),
        (BinaryOp::Gt, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Bool(a > b)),
        (BinaryOp::Le, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Bool(a <= b)),
        (BinaryOp::Ge, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Bool(a >= b)),
        (BinaryOp::And, ConstValue::Bool(a), ConstValue::Bool(b)) => Some(ConstValue::Bool(a && b)),
        (BinaryOp::Or, ConstValue::Bool(a), ConstValue::Bool(b)) => Some(ConstValue::Bool(a || b)),
        (BinaryOp::BitOr, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Int(a | b)),
        (BinaryOp::BitAnd, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Int(a & b)),
        (BinaryOp::BitXor, ConstValue::Int(a), ConstValue::Int(b)) => Some(ConstValue::Int(a ^ b)),
        (BinaryOp::Shl, ConstValue::Int(a), ConstValue::Int(b)) if (0..64).contains(&b) => {
            Some(ConstValue::Int(a.wrapping_shl(b as u32)))
        }
        (BinaryOp::Shr, ConstValue::Int(a), ConstValue::Int(b)) if (0..64).contains(&b) => {
            Some(ConstValue::Int(a.wrapping_shr(b as u32)))
        }
        _ => None,
    }
}

fn apply_unary(op: UnaryOp, v: ConstValue) -> Option<ConstValue> {
    match (op, v) {
        (UnaryOp::Neg, ConstValue::Int(n)) => Some(ConstValue::Int(-n)),
        (UnaryOp::Not, ConstValue::Bool(b)) => Some(ConstValue::Bool(!b)),
        _ => None,
    }
}

fn eval_comptime_function(
    f: &Function,
    args: &[ConstValue],
    functions: &HashMap<String, Function>,
    depth: usize,
) -> Result<ConstValue, NyraError> {
    if f.params.len() != args.len() {
        return Err(comptime_error(
            f.span.clone(),
            format!(
                "comptime function `{}` expected {} arguments, got {}",
                f.name,
                f.params.len(),
                args.len()
            ),
        ));
    }
    let mut env = HashMap::new();
    for (p, v) in f.params.iter().zip(args.iter()) {
        env.insert(p.name.clone(), v.clone());
    }
    eval_comptime_block(&f.body, &mut env, functions, depth, true)
}

fn eval_comptime_block(
    block: &Block,
    env: &mut HashMap<String, ConstValue>,
    functions: &HashMap<String, Function>,
    depth: usize,
    must_return: bool,
) -> Result<ConstValue, NyraError> {
    let mut steps = 0usize;
    match eval_comptime_block_inner(block, env, functions, depth, &mut steps)? {
        Some(v) => Ok(v),
        None if must_return => Err(comptime_error(
            Span::default(),
            "comptime function fell through without `return`",
        )),
        None => Err(comptime_error(Span::default(), "comptime block missing value")),
    }
}

fn eval_comptime_block_inner(
    block: &Block,
    env: &mut HashMap<String, ConstValue>,
    functions: &HashMap<String, Function>,
    depth: usize,
    steps: &mut usize,
) -> Result<Option<ConstValue>, NyraError> {
    for stmt in &block.statements {
        *steps += 1;
        if *steps > MAX_COMPTIME_STEPS {
            return Err(comptime_error(
                stmt_span(stmt),
                "comptime evaluation exceeded step limit",
            ));
        }
        match stmt {
            Statement::Let(l) => {
                let v = eval_comptime_expr(&l.value, env, functions, depth)?;
                env.insert(l.name.clone(), v);
            }
            Statement::Const(l) => {
                let v = eval_comptime_expr(&l.value, env, functions, depth)?;
                env.insert(l.name.clone(), v);
            }
            Statement::Assign(a) => {
                let v = eval_comptime_expr(&a.value, env, functions, depth)?;
                if let Expression::Variable { name, span } = &a.target {
                    if env.contains_key(name) {
                        env.insert(name.clone(), v);
                    } else {
                        return Err(comptime_error(
                            span.clone(),
                            format!("cannot assign unknown comptime variable `{name}`"),
                        ));
                    }
                } else {
                    return Err(comptime_error(
                        a.span.clone(),
                        "comptime assignment supports simple variables only",
                    ));
                }
            }
            Statement::Return(r) => {
                return match &r.value {
                    Some(v) => eval_comptime_expr(v, env, functions, depth).map(Some),
                    None => Err(comptime_error(
                        Span::default(),
                        "comptime return requires a value",
                    )),
                };
            }
            Statement::If(i) => {
                let cond = eval_comptime_expr(&i.condition, env, functions, depth)?;
                let branch = match cond {
                    ConstValue::Bool(true) => Some(&i.then_block),
                    ConstValue::Bool(false) => i.else_block.as_ref(),
                    _ => {
                        return Err(comptime_error(
                            Span::default(),
                            "comptime if condition must be bool",
                        ));
                    }
                };
                if let Some(branch) = branch {
                    if let Some(v) =
                        eval_comptime_block_inner(branch, env, functions, depth, steps)?
                    {
                        return Ok(Some(v));
                    }
                }
            }
            Statement::For(f) => {
                if f.parallel.is_some() || f.progress.is_some() {
                    return Err(comptime_error(
                        stmt_span(stmt),
                        "comptime `for` loops cannot use parallel/progress modifiers",
                    ));
                }
                match &f.kind {
                    ForKind::Range { start, end } => {
                        let start_v = eval_comptime_expr(start, env, functions, depth)?;
                        let end_v = eval_comptime_expr(end, env, functions, depth)?;
                        let (start_i, end_i) = match (start_v, end_v) {
                            (ConstValue::Int(s), ConstValue::Int(e)) => (s, e),
                            _ => {
                                return Err(comptime_error(
                                    stmt_span(stmt),
                                    "comptime range bounds must be integers",
                                ));
                            }
                        };
                        let mut i = start_i;
                        while i < end_i {
                            env.insert(f.var.clone(), ConstValue::Int(i));
                            if let Some(v) = eval_comptime_block_inner(
                                &f.body, env, functions, depth, steps,
                            )? {
                                return Ok(Some(v));
                            }
                            i += 1;
                        }
                    }
                    ForKind::Iterable { .. } => {
                        return Err(comptime_error(
                            stmt_span(stmt),
                            "comptime `for x in arr` is not supported yet; use `for i in 0..N`",
                        ));
                    }
                }
            }
            Statement::Expression(e) => {
                eval_comptime_expr(e, env, functions, depth)?;
            }
            Statement::Print(_)
            | Statement::Spawn(_)
            | Statement::Defer(_)
            | Statement::Unsafe(_)
            | Statement::Asm { .. }
            | Statement::Benchmark(_) => {
                return Err(comptime_error(
                    stmt_span(stmt),
                    "forbidden statement in comptime evaluation",
                ));
            }
            _ => {
                return Err(comptime_error(
                    stmt_span(stmt),
                    "unsupported statement in comptime evaluation",
                ));
            }
        }
    }
    Ok(None)
}

#[cfg(test)]
mod tests {
    use super::*;
    use ast::Literal;

    fn parse(src: &str) -> Program {
        let (tokens, _) = lexer::Lexer::new(src, "test.ny").tokenize();
        let (program, errs) = parser::Parser::new(tokens).parse();
        assert!(errs.is_empty(), "{errs:?}");
        program
    }

    #[test]
    fn comptime_module_folds_const_call() {
        let mut program = parse(
            r#"comptime

fn mix(n) {
    return n * 3
}

pub const ANSWER = mix(14)
"#,
        );
        assert!(program.comptime);
        let errors = finalize_comptime_module(&mut program);
        assert!(errors.is_empty(), "{errors:?}");
        assert!(program.functions.is_empty());
        assert_eq!(program.consts.len(), 1);
        assert!(matches!(
            program.consts[0].value,
            Expression::Literal(Literal::Int(42))
        ));
    }

    #[test]
    fn comptime_rejects_main() {
        let mut program = parse(
            r#"comptime
fn main() {
    return 0
}
"#,
        );
        let errors = finalize_comptime_module(&mut program);
        assert!(errors.iter().any(|e| e.message.contains("main")));
    }

    #[test]
    fn comptime_for_loop_accumulator() {
        let mut program = parse(
            r#"comptime

fn sum_to(n) {
    let mut acc = 0
    for i in 0..n {
        acc = acc + i
    }
    return acc
}

const TOTAL = sum_to(5)
"#,
        );
        let errors = finalize_comptime_module(&mut program);
        assert!(errors.is_empty(), "{errors:?}");
        assert!(matches!(
            program.consts[0].value,
            Expression::Literal(Literal::Int(10))
        ));
    }
}
