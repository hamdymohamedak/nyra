//! Conformance tests: f32 floating-point (CONF-F32-*).

use crate::common::compile;

#[test]
fn conf_f32_001_literal_suffix() {
    let out = compile(
        r#"fn main() {
    let x = 1.5f32
    print(x)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("float"), "{ir}");
    assert!(!ir.contains("double double"), "{ir}");
}

#[test]
fn conf_f32_002_explicit_annotation() {
    let out = compile(
        r#"fn main() {
    let radius: f32 = 2.0
    print(radius)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_f32_003_mixed_with_f64_promotes() {
    let out = compile(
        r#"fn main() {
    let a = 1.0f32 + 2.0
    print(a)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("double"), "{ir}");
}

#[test]
fn conf_f32_004_f32_arithmetic() {
    let out = compile(
        r#"fn main() {
    let x: f32 = 1.5
    let y: f32 = 2.5
    print(x + y)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("fadd float"), "{ir}");
}
