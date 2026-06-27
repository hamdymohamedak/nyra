//! Conformance tests: f64 floating-point (CONF-F64-*).

use crate::common::compile;

#[test]
fn conf_f64_001_literal_infers_f64() {
    let out = compile(
        r#"fn main() {
    let x = 3.14
    print(x)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty());
    let ir = out.llvm_ir.expect("ir");
    assert!(
        !ir.contains("double double"),
        "printf must not duplicate double keyword:\n{ir}"
    );
}

#[test]
fn conf_f64_002_explicit_annotation() {
    let out = compile(
        r#"fn main() {
    let price: f64 = 19.99
    print(price)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty());
}

#[test]
fn conf_f64_003_mixed_int_float_promotion() {
    let out = compile(
        r#"fn main() {
  let a = 1 + 2.5
  let b = 3.14 + 1
  print(a)
  print(b)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty());
}

#[test]
fn conf_f64_004_llvm_double_arithmetic() {
    let out = compile(
        r#"fn main() {
    let x: f64 = 1.5
    let y: f64 = 2.5
    print(x + y)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("double"), "{ir}");
    assert!(ir.contains("fadd"), "{ir}");
}

#[test]
fn conf_f64_005_struct_f64_fields_copy() {
    let out = compile(
        r#"struct Geo {
    lat: f64
    lng: f64
}
fn main() {
    let g1 = Geo { lat: 30.0 lng: 31.0 }
    let g2 = g1
    print(g1.lat)
    print(g2.lng)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_f64_006_comparisons() {
    let out = compile(
        r#"fn main() {
    let x: f64 = 3.14
    if x < 10.0 {
        print(1)
    }
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("fcmp"), "{ir}");
}
