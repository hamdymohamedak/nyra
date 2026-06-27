use compiler::{CompileOptions, Compiler};

fn compile(src: &str) -> compiler::CompileOutput {
    Compiler::compile_source(src, "os.ny", &CompileOptions::default()).unwrap()
}

#[test]
fn asm_requires_unsafe() {
    let out = compile(
        r#"fn main() {
    asm "nop"
}"#,
    );
    assert!(!out.type_errors.is_empty());
    assert!(out
        .type_errors
        .iter()
        .any(|e| e.message.contains("unsafe")));
}

#[test]
fn asm_in_unsafe_emits_inline_asm() {
    let out = compile(
        r#"fn main() {
    unsafe {
        asm "nop"
    }
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.unwrap();
    assert!(ir.contains("asm sideeffect"));
}

#[test]
fn os_platform_symbols_resolve() {
    let src = r#"
extern fn os_platform_name() -> string

fn main() {
    print(os_platform_name())
}
"#;
    let out = Compiler::compile_source(src, "main.ny", &CompileOptions::default()).unwrap();
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.unwrap();
    assert!(ir.contains("os_platform_name"));
}
