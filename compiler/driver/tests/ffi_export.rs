fn compile(src: &str, file: &str) -> compiler::CompileOutput {
    compiler::Compiler::compile_source(src, file, &compiler::CompileOptions::default())
        .expect("compile driver")
}

#[test]
fn export_fn_emits_unmangled_symbol() {
    let src = r#"
export fn add(a: i32, b: i32) -> i32 {
    return a + b
}
"#;
    let out = compile(src, "export.ny");
    assert!(out.lexer_errors.is_empty() && out.parser_errors.is_empty());
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("define i32 @add("));
}

#[test]
fn export_fn_string_return_uses_ptr() {
    let src = r#"
export fn greet(name: string) -> string {
    return name
}
"#;
    let out = compile(src, "greet.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("define ptr @greet("));
}

#[test]
fn export_fn_repr_c_struct_param_uses_pointer() {
    let src = r#"
struct Point repr(C) {
    x: i32
    y: i32
}
export fn get_x(p: Point) -> i32 {
    return p.x
}
"#;
    let out = compile(src, "point.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("define i32 @get_x(%Point*"));
}

#[test]
fn extern_callback_lowers_to_ptr() {
    let src = r#"
extern fn register(cb: fn(i32) -> void) -> void
fn main() {
}
"#;
    let out = compile(src, "cb.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("declare void @register("));
    assert!(ir.contains("ptr"));
}

#[test]
fn export_fn_rejects_non_repr_c_struct() {
    let src = r#"
struct Point {
    x: i32
}
export fn get_x(p: Point) -> i32 {
    return p.x
}
"#;
    let out = compile(src, "bad_export.ny");
    assert!(
        !out.type_errors.is_empty(),
        "expected FFI boundary error, got {:?}",
        out.type_errors
    );
    assert!(
        out.type_errors
            .iter()
            .any(|e| e.message.contains("FFI boundary")),
        "{:?}",
        out.type_errors
    );
}

#[test]
fn export_async_fn_returns_i32_handle() {
    let src = r#"
export async fn work() -> i32 {
    return 42
}
"#;
    let out = compile(src, "async_export.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("define i32 @work("));
}

#[test]
fn export_enum_param_lowers_to_i32() {
    let src = r#"
enum Color {
    Red
    Blue
}
export fn tag_of(c: Color) -> i32 {
    return 0
}
"#;
    let out = compile(src, "enum_export.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("define i32 @tag_of(i32"));
}

#[test]
fn export_generic_inst_emits_mangled_symbol() {
    let src = r#"
export fn id<T>(x: T) -> T {
    return x
}
export inst id<i32>
"#;
    let out = compile(src, "generic_export.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("define i32 @id__i32("));
    assert!(!ir.contains("define i32 @id("));
}

#[test]
fn extern_strlen_compiles() {
    let src = r#"
extern fn strlen(s: string) -> i32
fn main() {
    let n = strlen("hi")
    print(n)
}
"#;
    let out = compile(src, "strlen.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("declare i32 @str_len("));
}

#[test]
fn repr_c_struct_parses() {
    let src = r#"
struct Point repr(C) {
    x: i32
    y: i32
}
fn main() {
    let p = Point { x: 1, y: 2 }
    print(p.x)
}
"#;
    let out = compile(src, "repr.ny");
    assert!(out.parser_errors.is_empty(), "{:?}", out.parser_errors);
}
