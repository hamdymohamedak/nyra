//! Desugar `fn main(args: StrVec)` by injecting argv init into `main`.

use ast::*;

fn is_argv_param(param: &Param) -> bool {
    matches!(&param.ty, TypeAnnotation::Struct(name) if name == "StrVec")
        || param.name == "args"
        || matches!(&param.ty, TypeAnnotation::Generic(_))
}

pub fn desugar_main_argv(program: &mut Program) {
    let Some(idx) = program
        .functions
        .iter()
        .position(|f| f.name == "main" && f.params.len() == 1 && is_argv_param(&f.params[0]))
    else {
        return;
    };

    let main_fn = &mut program.functions[idx];
    let param_name = main_fn.params[0].name.clone();
    let span = main_fn.span.clone();

    let argv_init = Statement::Let(LetStmt {
        mutable: false,
        name: param_name,
        destructure: vec![],
        ty: Some(TypeAnnotation::Struct("StrVec".into())),
        value: Expression::Call(CallExpr {
            callee: "StrVec_from_argv".into(),
            type_args: vec![],
            args: vec![Expression::Literal(Literal::Int(1))],
            span: span.clone(),
        }),
        span: span.clone(),
    });

    main_fn.params.clear();
    let mut body = vec![argv_init];
    body.append(&mut main_fn.body.statements);
    main_fn.body.statements = body;
}
