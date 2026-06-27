use std::path::PathBuf;

use compiler::{CompileOptions, Compiler};

fn compile(src: &str) -> compiler::CompileOutput {
    Compiler::compile_source(src, "ownership.ny", &CompileOptions::default()).unwrap()
}

#[test]
fn copy_i32_both_usable_after_assign() {
    let out = compile(
        r#"fn main() {
    let x = 1
    let y = x
    print(x)
    print(y)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn string_use_after_move_rejected() {
    let out = compile(
        r#"fn main() {
    let a = "hi"
    let b = a
    print(a)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    assert!(out
        .borrow_errors
        .iter()
        .any(|e| e.message.contains("moved")));
}

#[test]
fn warns_on_manual_nyra_free_of_owned_binding() {
    let out = compile(
        r#"extern fn read_file(path: string) -> string
extern fn free(p: string) -> void

fn main() {
    let s = read_file("f.txt")
    free(s)
}"#,
    );
    assert!(out
        .borrow_errors
        .iter()
        .any(|e| e.message.contains("double-free") || e.message.contains("auto-drops")));
}

#[test]
fn rejects_return_ref_to_local() {
    let out = compile(
        r#"fn bad() -> &string {
    let s = "x"
    return &s
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    assert!(out
        .borrow_errors
        .iter()
        .any(|e| e.message.contains("reference to local")));
}

#[test]
fn auto_drop_emits_nyra_free_in_ir() {
    let out = compile(
        r#"extern fn read_file(path: string) -> string

fn main() {
    let content = read_file("/tmp/x")
    print(content)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    let ir = out.llvm_ir.expect("llvm");
    assert!(ir.contains("call void @heap_free"));
}

#[test]
fn read_file_example_compiles_without_manual_free() {
    let path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("../../examples/projects/read_file/main.ny");
    let src = std::fs::read_to_string(&path).expect("read example");
    let out = compile(&src);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    assert!(out.llvm_ir.is_some());
}
