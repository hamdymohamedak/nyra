//! Conformance tests: auto-borrow coercion (CONF-COERCE-*).

use crate::common::compile;

#[test]
fn conf_coerce_001_auto_borrow_ref_param() {
    let out = compile(
        r#"struct User {
    name: string
    age: i32
}
fn save(u: &User) -> void {
    print(u.age)
}
fn main() {
    let user = User { name: "Ahmed" age: 25 }
    save(user)
    print(user.age)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_coerce_002_owned_param_moves() {
    let out = compile(
        r#"struct User {
    name: string
    age: i32
}
fn consume(u: User) -> void {
    print(u.age)
}
fn main() {
    let user = User { name: "Ahmed" age: 25 }
    consume(user)
    print(user.age)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
}

#[test]
fn conf_coerce_003_string_clone_after_use() {
    let out = compile(
        r#"fn main() {
    let s = "hello"
    let copy = s.clone()
    print(s)
    print(copy)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_coerce_004_use_after_move_has_help() {
    let out = compile(
        r#"fn take(s: string) -> void {
    print(s)
}
fn main() {
    let s = "hello"
    take(s)
    print(s)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    let msg = format!("{:?}", out.borrow_errors);
    assert!(msg.contains("was moved into") || msg.contains("clone"));
}
