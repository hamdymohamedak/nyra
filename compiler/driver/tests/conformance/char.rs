//! Conformance tests: char Unicode scalar (CONF-CHAR-*).

use crate::common::compile;

#[test]
fn conf_char_001_literal_infers_char() {
    let out = compile(
        r#"fn main() {
    let c = 'A'
    print(c)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty());
}

#[test]
fn conf_char_002_explicit_annotation() {
    let out = compile(
        r#"fn main() {
    let ch: char = 'Z'
    print(ch)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_char_003_escape_sequences() {
    let out = compile(
        r#"fn main() {
    let nl = '\n'
    let tab = '\t'
    let slash = '\\'
    print(nl)
    print(tab)
    print(slash)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_char_004_comparison() {
    let out = compile(
        r#"fn main() {
    let c = 'A'
    if c == 'A' {
        print(1)
    }
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("icmp"), "{ir}");
}

#[test]
fn conf_char_005_struct_char_field_copy() {
    let out = compile(
        r#"struct Key {
    code: char
}
fn main() {
    let k1 = Key { code: 'X' }
    let k2 = k1
    print(k1.code)
    print(k2.code)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_char_006_print_char() {
    let out = compile(
        r#"fn main() {
    print('A')
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("%c"), "{ir}");
}
