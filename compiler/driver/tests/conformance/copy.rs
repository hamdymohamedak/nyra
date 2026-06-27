//! Conformance tests: auto Copy inference (CONF-COPY-*).

use crate::common::compile;

#[test]
fn conf_copy_001_auto_copy_struct_assign() {
    let out = compile(
        r#"struct Point {
    x: i32
    y: i32
}
fn main() {
    let p1 = Point { x: 1 y: 2 }
    let p2 = p1
    print(p1.x)
    print(p2.y)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_copy_002_string_field_struct_moves() {
    let out = compile(
        r#"struct User {
    name: string
}
fn main() {
    let u1 = User { name: "Ada" }
    let u2 = u1
    print(u1.name)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    let msg = format!("{:?}", out.borrow_errors);
    assert!(msg.contains("moved"), "{msg}");
}

#[test]
fn conf_copy_003_derive_copy_on_invalid_struct() {
    let out = compile(
        r#"#[derive(Copy)]
struct Bad {
    label: string
}
fn main() {
    let b = Bad { label: "x" }
    print(b.label)
}"#,
    );
    assert!(
        !out.type_errors.is_empty() || !out.borrow_errors.is_empty() || !out.parser_errors.is_empty(),
        "expected error for non-Copy derive"
    );
    let msg = format!(
        "{:?} {:?} {:?}",
        out.type_errors, out.borrow_errors, out.parser_errors
    );
    assert!(msg.contains("Copy"), "{msg}");
}

#[test]
fn conf_copy_004_nested_all_copy_struct() {
    let out = compile(
        r#"struct Point {
    x: i32
    y: i32
}
struct Rect {
    top_left: Point
    bottom_right: Point
}
fn main() {
    let r1 = Rect {
        top_left: Point { x: 0 y: 0 }
        bottom_right: Point { x: 10 y: 10 }
    }
    let r2 = r1
    print(r1.top_left.x)
    print(r2.bottom_right.y)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_copy_005_derive_copy_on_valid_struct() {
    let out = compile(
        r#"#[derive(Copy)]
struct Color {
    r: i32
    g: i32
    b: i32
}
fn main() {
    let a = Color { r: 1 g: 2 b: 3 }
    let b = a
    print(a.r)
    print(b.g)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}
