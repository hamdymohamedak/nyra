fn compile(src: &str) -> compiler::CompileOutput {
    let options = compiler::CompileOptions::default();
    compiler::Compiler::compile_source(src, "test.ny", &options).expect("compile")
}

#[test]
fn async_fn_no_extended_warning_v12() {
    let out = compile(
        r#"
async fn work() -> i32 {
    return 1
}
fn main() {
    return 0
}
"#,
    );
    assert!(out.type_errors.is_empty());
    assert!(out.borrow_errors.is_empty());
    assert!(
        out.warnings.is_empty(),
        "v1.2: async is Stable Extended, expected no W001: {:?}",
        out.warnings
    );
}

#[test]
fn deny_extended_allows_async_v12() {
    let options = compiler::CompileOptions {
        deny_extended: true,
        ..Default::default()
    };
    let out = compiler::Compiler::compile_source(
        r#"
async fn work() -> i32 {
    return 1
}
fn main() {
    return 0
}
"#,
        "test.ny",
        &options,
    )
    .expect("compile");
    assert!(!compiler::Compiler::report_errors(&out));
}

#[test]
fn core_hello_has_no_extended_warnings() {
    let out = compile(
        r#"
fn main() {
    print("hello")
}
"#,
    );
    assert!(out.warnings.is_empty());
}

#[test]
fn traits_macros_no_extended_warning_v12() {
    let out = compile(
        r#"
trait Greet {
    fn hello(self) -> void
}
macro shout(x) { x + x }
fn main() {
    let n = shout(1)
    print(n)
}
"#,
    );
    assert!(out.warnings.is_empty(), "got {:?}", out.warnings);
}
