//! Conformance tests: borrow checker (CONF-BOR-*).

use crate::common::compile;

#[test]
fn conf_bor_001_mut_borrow_while_imm_active() {
    let out = compile(
        r#"fn main() {
    let mut v = 1
    let r = &v
    v = 2
    print(r)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
}

#[test]
fn conf_bor_002_use_after_move_string() {
    let out = compile(
        r#"fn main() {
    let s = "a"
    let t = s
    print(s)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
}

#[test]
fn conf_bor_003_nll_borrow_ends_at_last_use() {
    let out = compile(
        r#"fn main() {
    let mut v = 1
    let r = &v
    print(r)
    v = 2
    print(v)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_bor_004_copy_i32_both_usable() {
    let out = compile(
        r#"fn main() {
    let a = 1
    let b = a
    print(a)
    print(b)
}"#,
    );
    assert!(out.borrow_errors.is_empty());
}

#[test]
fn conf_bor_005_assign_to_immutable() {
    let out = compile(
        r#"fn main() {
    let x = 1
    x = 2
}"#,
    );
    assert!(!out.type_errors.is_empty());
}

#[test]
fn conf_bor_006_reborrow_immut_ok() {
    let out = compile(
        r#"fn main() {
    let mut v = 1
    let r1 = &v
    let r2 = &v
    print(r1)
    print(r2)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_bor_007_mut_borrow_blocks_second_mut() {
    let out = compile(
        r#"fn main() {
    let mut v = 1
    let r = &mut v
    v = 2
    print(r)
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
}

#[test]
fn conf_bor_008_move_then_copy_int_ok() {
    let out = compile(
        r#"fn main() {
    let n = 42
    let m = n
    print(n)
}"#,
    );
    assert!(out.borrow_errors.is_empty());
}

#[test]
fn conf_bor_009_ref_to_local_in_fn_param_ok() {
    let out = compile(
        r#"fn show(p: &i32) -> void { print(p) }
fn main() {
    let x = 5
    show(&x)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn conf_bor_010_spawn_capture_send_field() {
    let out = compile(
        r#"fn main() {
    let n = 99
    spawn { print(n) }
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}
