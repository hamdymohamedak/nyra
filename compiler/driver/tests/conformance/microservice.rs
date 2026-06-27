//! Conformance tests: microservice async bootstrap (CONF-MSVC-*).

use crate::common::{assert_ir_patterns, compile_file_rel};

#[test]
fn conf_msvc_001_microservice_async_smoke() {
    let out = compile_file_rel("examples/microservice_async_smoke.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    let ir = out.llvm_ir.expect("ir");
    assert_ir_patterns(
        &ir,
        &["async_promise_new", "spawn_capture", "async_await"],
        &[],
    );
}

#[test]
fn conf_msvc_002_team_api_project_compiles() {
    let out = compile_file_rel("examples/projects/team_api/main.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_msvc_003_enterprise_platform_smoke() {
    let out = compile_file_rel("examples/projects/enterprise_platform/main.ny");
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.borrow_errors.is_empty(), "{:?}", out.borrow_errors);
    assert!(out.llvm_ir.is_some());
}
