use compiler::{CompileOptions, CompileStage, Compiler};

#[test]
fn const_fold_and_match_guard() {
    let src = r#"
enum E { A, B }
const TAG = 0
fn main() {
    let x = E.A
    let n = match x {
        E.A if TAG == 0 => 10
        _ => 0
    }
    print(n)
}
"#;
    let out = Compiler::compile_source(src, "t.ny", &CompileOptions::default()).unwrap();
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn generic_monomorph_compiles() {
    let src = r#"
fn id<T>(x: T) -> T {
    x
}
fn main() {
    let a = id<i32>(1)
    print(a)
}
"#;
    let out = Compiler::compile_source(src, "g.ny", &CompileOptions::default()).unwrap();
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.unwrap();
    assert!(ir.contains("id__i32") || ir.contains("@id"));
}

#[test]
fn borrow_check_runs_in_check_pipeline() {
    let src = r#"
fn main() {
    let a = "hi"
    let b = a
    print(a)
}
"#;
    let options = CompileOptions {
        stop_after: Some(CompileStage::Borrow),
        ..CompileOptions::default()
    };
    let out = Compiler::compile_source(src, "b.ny", &options).unwrap();
    assert!(!out.borrow_errors.is_empty());
}
