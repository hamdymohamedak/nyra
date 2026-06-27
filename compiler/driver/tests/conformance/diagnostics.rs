//! Conformance tests: ownership diagnostics (CONF-DIAG-*).

use crate::common::compile;

fn all_errors(out: &compiler::CompileOutput) -> String {
    format!("{:?}", out.borrow_errors)
}

#[test]
fn conf_diag_001_move_into_call_message() {
    let out = compile(
        r#"struct User {
    name: string
    age: i32
}
fn save(u: User) -> void {
    print(u.age)
}
fn main() {
    let user = User { name: "Ada" age: 30 }
    save(user)
    print(user.age)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    let msg = all_errors(&out);
    assert!(msg.contains("was moved into `save()`"), "{msg}");
}

#[test]
fn conf_diag_002_owned_param_suggests_clone_and_move() {
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
    let msg = all_errors(&out);
    assert!(msg.contains("expects ownership"), "{msg}");
    assert!(msg.contains("clone s"), "{msg}");
    assert!(msg.contains("move s"), "{msg}");
}

#[test]
fn conf_diag_003_borrow_param_suggests_auto_borrow() {
    let out = compile(
        r#"struct User {
    name: string
    age: i32
}
fn peek(u: &User) -> void {
    print(u.age)
}
fn main() {
    let user = User { name: "Ada" age: 30 }
    peek(move user)
    print(user.age)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    let msg = all_errors(&out);
    assert!(msg.contains("accepts a borrow"), "{msg}");
    assert!(msg.contains("auto-borrow"), "{msg}");
}

#[test]
fn conf_diag_004_clone_prefix_preserves_binding() {
    let out = compile(
        r#"fn take(s: string) -> void {
    print(s)
}
fn main() {
    let s = "hello"
    take(clone s)
    print(s)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_diag_005_move_prefix_skips_auto_borrow() {
    let out = compile(
        r#"struct User {
    name: string
    age: i32
}
fn save(u: &User) -> void {
    print(u.age)
}
fn main() {
    let user = User { name: "Ada" age: 30 }
    save(move user)
    print(user.name)
}"#,
    );
    assert!(!out.borrow_errors.is_empty(), "expected move despite &User param");
    let msg = all_errors(&out);
    assert!(msg.contains("was moved into `save()`"), "{msg}");
}
