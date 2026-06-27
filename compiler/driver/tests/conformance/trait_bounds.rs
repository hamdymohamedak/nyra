//! Conformance tests: trait bounds on generics (CONF-TRAIT-BOUND-*).

use crate::common::compile;

#[test]
fn conf_trait_bound_001_generic_with_impl_ok() {
    let out = compile(
        r#"trait Greet {
    fn hello(self) -> i32
}
struct User { score: i32 }
impl Greet for User {
    fn hello(self) -> i32 { return self.score }
}
fn call<T: Greet>(x: T) -> i32 { return x.hello() }
fn main() {
    let u = User { score: 5 }
    print(call(u))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_trait_bound_002_missing_impl_errors() {
    let out = compile(
        r#"trait Greet {
    fn hello(self) -> i32
}
struct Plain { n: i32 }
fn call<T: Greet>(x: T) -> i32 { return x.hello() }
fn main() {
    let p = Plain { n: 1 }
    print(call(p))
}"#,
    );
    assert!(
        !out.type_errors.is_empty(),
        "expected trait bound error, got {:?}",
        out.type_errors
    );
    assert!(
        out.type_errors
            .iter()
            .any(|e| e.message.contains("does not implement trait")),
        "{:?}",
        out.type_errors
    );
}
