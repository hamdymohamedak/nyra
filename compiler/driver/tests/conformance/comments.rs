//! Conformance tests: comments (CONF-COMMENT-*).

use compiler::parse_source;
use crate::common::compile;

#[test]
fn conf_comment_001_block_comment_inline() {
    let out = compile(
        r#"fn main() {
    let x = 1 /* add */ + 2
    print(x)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_comment_002_block_comment_multiline() {
    let out = compile(
        r#"fn main() {
    /*
     * doc
     */
    print(7)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_comment_003_unclosed_block_comment_errors() {
    let out = compile(
        r#"fn main() {
    let x = 1 /* oops
    print(x)
}"#,
    );
    assert!(
        !out.lexer_errors.is_empty() || !out.type_errors.is_empty(),
        "expected lexer or parse error for unclosed block comment"
    );
}

#[test]
fn conf_comment_004_doc_comment_on_fn_and_struct() {
    let program = parse_source(
        r#"/// Greets someone.
fn greet() {
    print("hi")
}

/// A 2D point.
struct Point {
    x: i32
}
"#,
        "test.ny",
    )
    .expect("parse doc comments");
    assert_eq!(
        program.functions[0].doc.as_deref(),
        Some("Greets someone.")
    );
    assert_eq!(program.structs[0].doc.as_deref(), Some("A 2D point."));
}
