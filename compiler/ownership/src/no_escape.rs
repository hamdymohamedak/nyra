//! Validate `#[no_escape]` parameter contracts against escape analysis results.

use ast::{Function, Param, Program, TypeAnnotation};
use errors::{ErrorKind, NyraError};

use crate::escape::{EscapePlan, EscapeState};

fn is_ref_annotation(ann: &TypeAnnotation) -> bool {
    matches!(ann, TypeAnnotation::Ref { .. })
}

fn check_param_annotation(func: &Function, param: &Param, errors: &mut Vec<NyraError>) {
    if !param.no_escape {
        return;
    }
    if !is_ref_annotation(&param.ty) {
        errors.push(
            NyraError::coded(
                "E0601",
                ErrorKind::Type,
                func.span.clone(),
                format!(
                    "parameter `{}` has `#[no_escape]` but type is not a reference (`&T`)",
                    param.name
                ),
            )
            .note("Example: `fn f(#[no_escape] data: &string) { ... }`"),
        );
    }
}

fn check_param_escape(func: &Function, param: &Param, plan: &EscapePlan, errors: &mut Vec<NyraError>) {
    if !param.no_escape {
        return;
    }
    let state = plan.state_in(&func.name, &param.name);
    if state == EscapeState::GlobalEscape {
        errors.push(
            NyraError::coded(
                "E0602",
                ErrorKind::BorrowCheck,
                func.span.clone(),
                format!(
                    "parameter `{}` is marked `#[no_escape]` but escapes the function",
                    param.name
                ),
            )
            .note("Do not return, spawn-capture, or send this borrow across threads/channels"),
        );
    }
}

fn check_function(func: &Function, plan: &EscapePlan, errors: &mut Vec<NyraError>) {
    for param in &func.params {
        check_param_annotation(func, param, errors);
        check_param_escape(func, param, plan, errors);
    }
}

/// Reject `#[no_escape]` parameters that are not references or that escape the function.
pub fn check_no_escape(program: &Program, plan: &EscapePlan, errors: &mut Vec<NyraError>) {
    for func in &program.functions {
        if func.type_params.is_empty() {
            check_function(func, plan, errors);
        }
    }
    for imp in &program.impls {
        for method in &imp.methods {
            check_function(method, plan, errors);
        }
    }
    for ti in &program.trait_impls {
        for method in &ti.methods {
            check_function(method, plan, errors);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::escape::analyze_escapes;

    fn parse_program(src: &str) -> Program {
        let (tokens, _) = lexer::Lexer::new(src, "t.ny").tokenize();
        let (program, _) = parser::Parser::new(tokens).parse();
        program
    }

    fn plan_for(src: &str) -> EscapePlan {
        analyze_escapes(&parse_program(src))
    }

    #[test]
    fn no_escape_param_ok_when_local() {
        let src = r#"fn f(#[no_escape] data: &string) {
    let x = 1
    print(x)
}"#;
        let program = parse_program(src);
        let plan = plan_for(src);
        let mut errors = vec![];
        check_no_escape(&program, &plan, &mut errors);
        assert!(errors.is_empty(), "{errors:?}");
    }

    #[test]
    fn no_escape_param_rejects_return() {
        let src = r#"fn f(#[no_escape] data: &string) -> &string {
    return data
}"#;
        let program = parse_program(src);
        let plan = plan_for(src);
        let mut errors = vec![];
        check_no_escape(&program, &plan, &mut errors);
        assert!(errors.iter().any(|e| e.code.as_deref() == Some("E0602")));
    }

    #[test]
    fn no_escape_requires_ref_type() {
        let src = r#"fn f(#[no_escape] data: string) {
    print(data)
}"#;
        let program = parse_program(src);
        let plan = plan_for(src);
        let mut errors = vec![];
        check_no_escape(&program, &plan, &mut errors);
        assert!(errors.iter().any(|e| e.code.as_deref() == Some("E0601")));
    }
}
