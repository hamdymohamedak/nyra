use ast::Statement;
use lexer::Lexer;
use parser::Parser;

#[test]
fn parses_deref_assign_after_raw_ptr_let() {
    let src = r#"fn main() {
    mut x = 1
    unsafe {
        let p = &x as *i32
        *p = 7
    }
}"#;
    let (tokens, _) = Lexer::new(src, "t.ny").tokenize();
    let (prog, errors) = Parser::new(tokens).parse();
    assert!(errors.is_empty(), "{errors:?}");
    let Statement::Unsafe(block) = &prog.functions[0].body.statements[1] else {
        panic!("expected unsafe statement, got {:?}", prog.functions[0].body.statements);
    };
    assert_eq!(block.statements.len(), 2);
    assert!(matches!(&block.statements[1], Statement::Assign(_)));
}
