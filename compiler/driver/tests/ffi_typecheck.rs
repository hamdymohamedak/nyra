#[test]
fn export_fn_abi_rejects_non_repr_c_at_typecheck() {
    let src = r#"
struct Point {
    x: i32
}
export fn get_x(p: Point) -> i32 {
    return p.x
}
"#;
    let options = compiler::CompileOptions {
        stop_after: Some(compiler::CompileStage::TypeCheck),
        ..Default::default()
    };
    let out = compiler::Compiler::compile_source(src, "t.ny", &options).expect("compile");
    assert!(
        out.type_errors
            .iter()
            .any(|e| e.message.contains("FFI boundary")),
        "expected FFI error, got {:?}",
        out.type_errors
    );
}

#[test]
fn export_fn_abi_accepts_async_i32_at_typecheck() {
    let src = r#"
export async fn work() -> i32 {
    return 1
}
"#;
    let options = compiler::CompileOptions {
        stop_after: Some(compiler::CompileStage::TypeCheck),
        ..Default::default()
    };
    let out = compiler::Compiler::compile_source(src, "t.ny", &options).expect("compile");
    assert!(
        out.type_errors
            .iter()
            .all(|e| !e.message.contains("cannot be async")),
        "unexpected async error, got {:?}",
        out.type_errors
    );
}

#[test]
fn export_fn_abi_accepts_enum_array_tuple() {
    let src = r#"
enum Color {
    Red
    Blue
}
export fn pack(c: Color, buf: [i32; 2], pair: (i32, i32)) -> i32 {
    return pair.0
}
"#;
    let options = compiler::CompileOptions {
        stop_after: Some(compiler::CompileStage::TypeCheck),
        ..Default::default()
    };
    let out = compiler::Compiler::compile_source(src, "t.ny", &options).expect("compile");
    assert!(
        out.type_errors
            .iter()
            .all(|e| !e.message.contains("FFI boundary")),
        "unexpected FFI error, got {:?}",
        out.type_errors
    );
}

#[test]
fn export_inst_requires_generic_export() {
    let src = r#"
export fn plain(x: i32) -> i32 {
    return x
}
export inst plain<i32>
"#;
    let options = compiler::CompileOptions {
        stop_after: Some(compiler::CompileStage::TypeCheck),
        ..Default::default()
    };
    let out = compiler::Compiler::compile_source(src, "t.ny", &options).expect("compile");
    assert!(
        out.type_errors
            .iter()
            .any(|e| e.message.contains("only valid for generic")),
        "expected generic export inst error, got {:?}",
        out.type_errors
    );
}
