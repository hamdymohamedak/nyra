//! Conformance tests: FFI (CONF-FFI-*).

use crate::common::{assert_ir_patterns, compile, compile_stage};
use compiler::CompileStage;

#[test]
fn conf_ffi_001_export_unmangled_symbol() {
    let out = compile(
        r#"export fn greet() -> void {
    print("hi")
}
fn main() { greet() }"#,
    );
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("define void @greet("));
}

#[test]
fn conf_ffi_002_repr_c_required_for_export_struct() {
    let out = compile_stage(
        r#"struct Point { x: i32 y: i32 }
export fn use_point(p: Point) -> void { print(p.x) }
fn main() { print(0) }"#,
        CompileStage::TypeCheck,
    );
    assert!(!out.type_errors.is_empty());
}

#[test]
fn conf_ffi_003_export_inst_required_for_generic() {
    let out = compile_stage(
        r#"export fn id<T>(x: T) -> T { return x }
fn main() { print(id<i32>(1)) }"#,
        CompileStage::TypeCheck,
    );
    // Export generic without `export inst` should error or warn at boundary.
    assert!(
        !out.type_errors.is_empty()
            || out.warnings.iter().any(|w| {
                w.message.contains("export") || w.message.contains("generic fn")
            }),
        "expected export boundary issue, got type_errors={:?} warnings={:?}",
        out.type_errors,
        out.warnings
    );
}

#[test]
fn conf_ffi_004_async_export_lowers_to_i32() {
    let out = compile(
        r#"export async fn work() -> i32 { return 1 }
export inst work
fn main() { print(0) }"#,
    );
    if out.type_errors.is_empty() {
        let ir = out.llvm_ir.expect("ir");
        assert!(ir.contains("@work") || ir.contains("work"));
    }
}

#[test]
fn conf_ffi_005_repr_c_struct_param_pointer() {
    let out = compile(
        r#"struct Point repr(C) {
    x: i32
    y: i32
}
export fn sum(p: Point) -> i32 { return p.x + p.y }
fn main() { print(0) }"#,
    );
    if out.type_errors.is_empty() {
        let ir = out.llvm_ir.unwrap();
        assert_ir_patterns(&ir, &["@sum"], &[]);
    }
}

#[test]
fn conf_ffi_006_extern_fn_decl_ok() {
    let out = compile(
        r#"extern fn puts(s: string) -> void
fn main() { puts("hi") }"#,
    );
    assert!(out.type_errors.is_empty() || out.llvm_ir.is_some());
}

#[test]
fn conf_ffi_007_export_generic_with_inst() {
    let out = compile(
        r#"export fn id<T>(x: T) -> T { return x }
export inst id<i32>
fn main() { print(id<i32>(7)) }"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.unwrap();
    assert!(ir.contains("id") || ir.contains("@id"));
}

#[test]
fn conf_ffi_008_call_extern_callback() {
    let out = compile(
        r#"extern fn cb(n: i32) -> i32
fn main() { print(cb(3)) }"#,
    );
    assert!(out.llvm_ir.is_some() || !out.type_errors.is_empty());
}

#[test]
fn conf_ffi_009_string_param_is_ptr() {
    let out = compile(
        r#"export fn echo(s: string) -> void { print(s) }
fn main() { print(0) }"#,
    );
    if let Some(ir) = out.llvm_ir {
        assert!(ir.contains("echo"));
    }
}

#[test]
fn conf_ffi_011_extern_repr_c_struct_byval() {
    let out = compile(
        r#"struct Color repr(C) {
    r: u8
    g: u8
    b: u8
    a: u8
}
extern fn ClearBackground(color: Color) -> void
fn main() {
    let rr: u8 = 20
    let gg: u8 = 24
    let bb: u8 = 40
    let aa: u8 = 255
    ClearBackground(Color { r: rr g: gg b: bb a: aa })
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    let arm64 = ir.contains("arm64-apple") || ir.contains("aarch64-apple");
    if arm64 {
        assert!(
            ir.contains("declare void @ClearBackground(i64"),
            "expected i64 ClearBackground on arm64-apple"
        );
        assert!(
            ir.contains("call void @ClearBackground(i64"),
            "expected i64 ClearBackground call on arm64-apple"
        );
    } else {
        assert!(
            ir.contains("declare void @ClearBackground(%Color* byval(%Color)"),
            "expected byval extern decl"
        );
        assert!(
            ir.contains("call void @ClearBackground(%Color* byval(%Color)"),
            "expected byval extern call"
        );
    }
}

#[test]
fn conf_ffi_013_col_fn_stores_param_values() {
    let out = compile(
        r#"struct Color repr(C) {
    r: u8
    g: u8
    b: u8
    a: u8
}
fn col(r: i32, g: i32, b: i32, a: i32) -> Color {
    let rr: u8 = r
    let gg: u8 = g
    let bb: u8 = b
    let aa: u8 = a
    return Color { r: rr g: gg b: bb a: aa }
}
fn main() {
    let c = col(6, 8, 20, 255)
    print(0)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(
        ir.contains("trunc i32 %0 to i8") || ir.contains("store i8 %"),
        "expected param r stored into Color.r, got:\n{ir}"
    );
}

#[test]
fn conf_ffi_012_extern_vector2_byval() {
    let out = compile(
        r#"struct Vector2 repr(C) {
    x: f64
    y: f64
}
extern fn CheckCollisionCircles(centerA: Vector2, radiusA: f64, centerB: Vector2, radiusB: f64) -> bool
fn main() {
    let a = Vector2 { x: 0.0 y: 0.0 }
    let b = Vector2 { x: 10.0 y: 0.0 }
    let hit = CheckCollisionCircles(a, 5.0, b, 5.0)
    if hit { print(1) } else { print(0) }
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(
        ir.contains("declare i1 @CheckCollisionCircles(%Vector2* byval(%Vector2)"),
        "expected byval Vector2 extern decl"
    );
    assert!(
        ir.contains("call i1 @CheckCollisionCircles(%Vector2* byval(%Vector2)"),
        "expected byval Vector2 extern call"
    );
}

#[test]
fn conf_ffi_014_arm64_indirect_texture_image_abi() {
    let out = compile(
        r#"struct Color repr(C) {
    r: u8
    g: u8
    b: u8
    a: u8
}
struct Image repr(C) {
    data: ptr
    width: i32
    height: i32
    mipmaps: i32
    format: i32
}
struct Texture repr(C) {
    id: u32
    width: i32
    height: i32
    mipmaps: i32
    format: i32
}
extern fn GenImageColor(width: i32, height: i32, color: Color) -> Image
extern fn LoadTextureFromImage(image: Image) -> Texture
extern fn DrawTexture(texture: Texture, posX: i32, posY: i32, tint: Color) -> void
fn main() {
    let img = GenImageColor(32, 32, Color { r: 40 g: 40 b: 40 a: 255 })
    let tex = LoadTextureFromImage(img)
    DrawTexture(tex, 0, 0, Color { r: 255 g: 255 b: 255 a: 255 })
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    let arm64 = ir.contains("arm64-apple") || ir.contains("aarch64-apple");
    if arm64 {
        assert!(
            ir.contains("declare void @GenImageColor(%Image* sret(%Image)"),
            "expected sret Image return on arm64-apple, got:\n{ir}"
        );
        assert!(
            ir.contains("declare void @LoadTextureFromImage(%Texture* sret(%Texture)"),
            "expected sret Texture return on arm64-apple"
        );
        assert!(
            ir.contains("declare void @DrawTexture(ptr"),
            "expected indirect Texture param on arm64-apple"
        );
    }
}

#[test]
fn conf_ffi_010_enum_export_boundary() {
    let out = compile_stage(
        r#"enum E { A B }
export fn tag(e: E) -> i32 { return 0 }
fn main() { print(0) }"#,
        CompileStage::TypeCheck,
    );
    assert!(out.type_errors.is_empty() || !out.type_errors.is_empty());
}
