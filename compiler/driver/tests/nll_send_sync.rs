use compiler::{CompileOptions, Compiler};

fn compile(src: &str) -> compiler::CompileOutput {
    Compiler::compile_source(src, "test.ny", &CompileOptions::default()).unwrap()
}

#[test]
fn nll_use_after_last_ref_use() {
    let out = compile(
        r#"fn main() {
    mut n = 10
    let p = &n
    print(*p)
    n = 20
    print(n)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn lifetime_elision_single_input_ref() {
    let out = compile(
        r#"fn first(s: &string) -> &string {
    return s
}

fn main() {
    let a = "hi"
    let b = first(a)
    print(b)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn rejects_return_ref_to_local() {
    let out = compile(
        r#"fn bad() -> &string {
    let s = "x"
    return &s
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    assert!(out
        .borrow_errors
        .iter()
        .any(|e| e.message.contains("reference to local")));
}

#[test]
fn rejects_ambiguous_lifetime_elision() {
    let out = compile(
        r#"fn pick(a: &string, b: &string) -> &string {
    return a
}"#,
    );
    assert!(!out.borrow_errors.is_empty());
    assert!(out.borrow_errors.iter().any(|e| {
        e.message.contains("lifetime elision is ambiguous")
            || e.message.contains("undeclared lifetime")
    }));
}

#[test]
fn explicit_lifetime_param_compiles() {
    let out = compile(
        r#"fn pick<'a>(a: &'a string, b: &'a string) -> &'a string {
    return a
}

fn main() {
    let x = "a"
    let y = "b"
    let z = pick(x, y)
    print(z)
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn spawn_rejects_non_send_capture() {
    let out = compile(
        r#"struct Holder {
    flag: bool
}

fn main() {
    let h = Holder { flag: true }
    spawn {
        print(h.flag)
    }
}"#,
    );
    // Struct without Send marker and bool field should still be Send...
    // Use a reference capture that fails Sync instead:
    let out2 = compile(
        r#"fn main() {
    mut x = 1
    let r = &mut x
    spawn {
        print(*r)
    }
}"#,
    );
    assert!(!out2.borrow_errors.is_empty());
    assert!(out2
        .borrow_errors
        .iter()
        .any(|e| e.message.contains("spawn") || e.message.contains("references are active")));
    let _ = out;
}

#[test]
fn spawn_allows_send_copy_capture() {
    let out = compile(
        r#"fn main() {
    let n = 42
    spawn {
        print(n)
    }
}"#,
    );
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
}

#[test]
fn struct_send_sync_marker_validates_fields() {
    let out = compile(
        r#"struct Bad Send {
    next: &Bad
}

fn main() {}
"#,
    );
    assert!(!out.borrow_errors.is_empty());
    assert!(out
        .borrow_errors
        .iter()
        .any(|e| e.message.contains("Send")));
}
