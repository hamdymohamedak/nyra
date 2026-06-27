//! Conformance: Move-safe `Vec<T>` via parallel columns (CONF-VEC-RELOC-*).

use crate::common::compile_file_rel;

#[test]
fn conf_vec_reloc_001_label_row_file() {
    let out = compile_file_rel("tests/nyra/vec_reloc_test.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("Vec_str_push"), "expected reloc string column:\n{ir}");
    assert!(ir.contains("Vec_i32_push"), "expected reloc scalar column:\n{ir}");
}

#[test]
fn conf_vec_reloc_002_nested_file() {
    let out = compile_file_rel("tests/nyra/vec_reloc_test.typed.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(
        ir.contains("Vec_str_push"),
        "expected nested reloc columns:\n{ir}"
    );
}
