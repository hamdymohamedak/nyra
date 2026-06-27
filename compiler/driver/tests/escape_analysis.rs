use compiler::{CompileOptions, CompileStage, Compiler, EscapeState};

mod common;
use common::workspace_root;

fn compile_borrow(src: &str) -> compiler::CompileOutput {
    let options = CompileOptions {
        stop_after: Some(CompileStage::Borrow),
        verbose_escape: true,
        ..CompileOptions::default()
    };
    Compiler::compile_source(src, "escape.ny", &options).unwrap()
}

fn compile_ir(src: &str) -> String {
    Compiler::compile_source(src, "escape_codegen.ny", &CompileOptions::default())
        .unwrap()
        .llvm_ir
        .expect("llvm ir")
}

/// LLVM IR for `@main` only (stops before the next `define`).
fn main_ir(ir: &str) -> &str {
    let Some(after) = ir.split("define i32 @main").nth(1) else {
        return "";
    };
    let Some(open) = after.find('{') else {
        return "";
    };
    after[open..]
        .split("\ndefine ")
        .next()
        .unwrap_or(&after[open..])
}

#[test]
fn escape_plan_local_i32_no_escape() {
    let out = compile_borrow(
        r#"fn main() {
    let x = 42
    print(x)
}"#,
    );
    assert_eq!(out.escape_plan.state_in("main", "x"), EscapeState::NoEscape);
}

#[test]
fn escape_plan_return_string_global() {
    let out = compile_borrow(
        r#"fn mk() -> string {
    let s = "hi"
    return s
}"#,
    );
    assert_eq!(out.escape_plan.state_in("mk", "s"), EscapeState::GlobalEscape);
}

#[test]
fn escape_codegen_no_str_clone_for_no_escape_struct() {
    let ir = compile_ir(
        r#"struct User { id: i32 name: string }
fn main() {
    let user = User { id: 1 name: "Hamdy" }
    print(user.id)
}"#,
    );
    let body = main_ir(&ir);
    assert!(!body.contains("call ptr @str_clone"));
    assert!(!body.contains("call ptr @substring"));
}

#[test]
fn escape_codegen_sroa_copy_struct_no_struct_alloca() {
    let ir = compile_ir(
        r#"struct Point { x: i32 y: i32 }
fn main() {
    let p = Point { x: 1 y: 2 }
    print(p.x)
}"#,
    );
    assert!(!main_ir(&ir).contains("alloca %Point"));
}

#[test]
fn escape_codegen_return_struct_global_still_clones_strings() {
    let out = Compiler::compile_source(
        r#"struct User { id: i32 name: string }
fn mk() -> User {
    let user = User { id: 1 name: "Hamdy" }
    return user
}"#,
        "escape_codegen.ny",
        &CompileOptions::default(),
    )
    .unwrap();
    assert_eq!(
        out.escape_plan.state_in("mk", "user"),
        EscapeState::GlobalEscape
    );
    let ir = out.llvm_ir.expect("llvm ir");
    assert!(ir.contains("call ptr @str_clone"));
}

#[test]
fn escape_plan_param_return_global_escape() {
    let out = compile_borrow(
        r#"fn f(data: &string) -> &string {
    return data
}"#,
    );
    assert_eq!(out.escape_plan.state_in("f", "data"), EscapeState::GlobalEscape);
}

#[test]
fn no_escape_param_rejects_escaping_return() {
    let out = Compiler::compile_source(
        r#"fn f(#[no_escape] data: &string) -> &string {
    return data
}"#,
        "no_escape.ny",
        &CompileOptions::default(),
    )
    .unwrap();
    assert!(!out.borrow_errors.is_empty());
    assert!(out
        .borrow_errors
        .iter()
        .any(|e| e.message.contains("no_escape")));
}

#[test]
fn no_escape_param_ok_when_used_locally() {
    let out = Compiler::compile_source(
        r#"fn use_ref(#[no_escape] data: &string) {
    let x = 1
    print(x)
}
fn main() {
    use_ref("hi")
}"#,
        "no_escape.ny",
        &CompileOptions::default(),
    )
    .unwrap();
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    assert!(out.escape_plan.is_no_escape_param("use_ref", "data"));
    assert!(out.llvm_ir.is_some());
}

#[test]
fn no_escape_param_requires_ref_type() {
    let out = Compiler::compile_source(
        r#"fn f(#[no_escape] data: string) {
    print(data)
}"#,
        "no_escape.ny",
        &CompileOptions::default(),
    )
    .unwrap();
    assert!(!out.type_errors.is_empty());
    assert!(out
        .type_errors
        .iter()
        .any(|e| e.message.contains("no_escape")));
}

#[test]
fn escape_plan_spawn_capture_global() {
    let out = compile_borrow(
        r#"fn main() {
    let n = 42
    spawn { print(n) }
}"#,
    );
    assert_eq!(out.escape_plan.state_in("main", "n"), EscapeState::GlobalEscape);
}

#[test]
fn escape_codegen_local_channel_no_runtime_calls() {
    let out = Compiler::compile_source(
        r#"extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32
fn main() {
    let ch = channel_new()
    channel_send(ch, 42)
    let n = channel_recv(ch)
    print(n)
}"#,
        "escape_codegen.ny",
        &CompileOptions::default(),
    )
    .unwrap();
    assert!(out.escape_plan.is_local_channel("main", "ch"));
    let ir = out.llvm_ir.expect("llvm ir");
    let body = main_ir(&ir);
    assert!(body.contains("alloca %NyraLocalChannel_i32"));
    assert!(!body.contains("call ptr @channel_new"));
    assert!(!body.contains("call void @channel_send"));
    assert!(!body.contains("call i32 @channel_recv"));
    assert!(!out.runtime_profile.symbols.contains("channel_new"));
}

#[test]
fn escape_codegen_spawn_channel_uses_runtime() {
    let out = Compiler::compile_source(
        r#"extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32
fn main() {
    let ch = channel_new()
    spawn {
        channel_send(ch, 42)
    }
    print(channel_recv(ch))
}"#,
        "escape_codegen.ny",
        &CompileOptions::default(),
    )
    .unwrap();
    assert!(!out.escape_plan.is_local_channel("main", "ch"));
    let ir = out.llvm_ir.expect("llvm ir");
    assert!(ir.contains("call ptr @channel_new"));
    assert!(ir.contains("call void @channel_send"));
}

#[test]
fn escape_local_channel_file_no_duplicate_channel_declare() {
    let path = workspace_root().join("examples/comparison/escape/local_channel.ny");
    let out = Compiler::compile_file(&path, &CompileOptions::default()).unwrap();
    let ir = out.llvm_ir.expect("llvm ir");
    let count = ir.matches("declare ptr @channel_new()").count();
    assert_eq!(
        count, 1,
        "auto-prelude channel.ny + explicit nyra_channel_* extern must not duplicate declares"
    );
}

#[test]
fn lazy_prelude_slim_for_builtin_only_program() {
    let path = workspace_root().join("examples/comparison/cpu_bound/bench.ny");
    let with_prelude = Compiler::compile_file(&path, &CompileOptions::default()).unwrap();
    let without_prelude = Compiler::compile_file(
        &path,
        &CompileOptions {
            no_prelude: true,
            ..CompileOptions::default()
        },
    )
    .unwrap();
    let ir_lazy = with_prelude.llvm_ir.expect("lazy prelude ir");
    let ir_slim = without_prelude.llvm_ir.expect("no-prelude ir");
    let defines_lazy = ir_lazy.matches("\ndefine ").count() + if ir_lazy.starts_with("define ") {
        1
    } else {
        0
    };
    let defines_slim = ir_slim.matches("\ndefine ").count()
        + if ir_slim.starts_with("define ") {
            1
        } else {
            0
        };
    assert!(
        defines_lazy < 20,
        "lazy auto-prelude should not merge unused stdlib for bench.ny, got {defines_lazy}"
    );
    assert!(
        defines_slim < 20,
        "expected --no-prelude IR to stay small (main + runtime helpers), got {defines_slim}"
    );
    assert!(ir_slim.contains("define i32 @main"));
    assert!(
        ir_slim.contains("urem i32") || ir_slim.contains("and i32"),
        "expected strength-reduced modulo in slim IR"
    );
}

#[test]
fn lazy_prelude_includes_used_stdlib() {
    let path = workspace_root().join("tests/suite/run/stdlib/auto_prelude.ny");
    let with_prelude = Compiler::compile_file(&path, &CompileOptions::default()).unwrap();
    let without_prelude = Compiler::compile_file(
        &path,
        &CompileOptions {
            no_prelude: true,
            ..CompileOptions::default()
        },
    )
    .unwrap();
    assert!(
        without_prelude.llvm_ir.is_none() && !without_prelude.type_errors.is_empty(),
        "Vec_i32_new without prelude should fail typecheck"
    );
    let ir = with_prelude.llvm_ir.expect("lazy prelude ir");
    assert!(
        ir.contains("Vec_i32_new") || ir.contains("vec_i32_new"),
        "expected vec symbols in IR when program uses Vec_i32"
    );
}
