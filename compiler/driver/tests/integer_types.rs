//! Full i/u integer family (optional annotations).

mod common;

use crate::common::compile;

#[test]
fn integer_types_compile() {
    let out = compile(
        r#"fn main() {
    let a: i8 = 127
    let b: i16 = -1
    let c: i32 = 42
    let d: i64 = 1
    let e: i128 = 1
    let f: isize = -1
    let g: u8 = 255
    let h: u16 = 65535
    let i: u32 = 0
    let j: u64 = 1
    let k: u128 = 1
    let l: usize = 0
    print(a + b + c + g + l)
}"#,
    );
    assert!(
        out.type_errors.is_empty(),
        "type errors: {:?}",
        out.type_errors
    );
    assert!(out.llvm_ir.is_some(), "expected llvm ir");
}

#[test]
fn unsigned_rejects_negative_literal() {
    let out = compile(
        r#"fn main() {
    let age: u8 = -12
}"#,
    );
    assert!(
        out.type_errors.iter().any(|e| e.message.contains("out of range")),
        "expected out-of-range error, got: {:?}",
        out.type_errors
    );
}

#[test]
fn u8_rejects_overflow_literal() {
    let out = compile(
        r#"fn main() {
    let b: u8 = 256
}"#,
    );
    assert!(
        out.type_errors.iter().any(|e| e.message.contains("out of range")),
        "expected out-of-range error, got: {:?}",
        out.type_errors
    );
}
