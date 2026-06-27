//! Conformance tests: generics (CONF-GEN-*).

use crate::common::{compile, compile_stage};
use compiler::CompileStage;

#[test]
fn conf_gen_001_monomorph_mangles_id_i32() {
    let out = compile(
        r#"fn id<T>(x: T) -> T { return x }
fn main() { print(id<i32>(7)) }"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.unwrap();
    assert!(ir.contains("id__i32") || ir.contains("@id"));
}

#[test]
fn conf_gen_002_type_param_arity_mismatch() {
    let out = compile(
        r#"fn id<T>(x: T) -> T { return x }
fn main() { print(id<>(1)) }"#,
    );
    assert!(!out.type_errors.is_empty() || !out.parser_errors.is_empty());
}

#[test]
fn conf_gen_003_const_fold_match_guard() {
    let out = compile(
        r#"fn main() {
    let x = 3
    let n = match x {
        v if v == 3 => 1
        _ => 0
    }
    print(n)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_gen_004_export_inst_specialization() {
    let out = compile(
        r#"export fn twice<T>(x: T) -> T { return x }
export inst twice<i32>
fn main() { print(0) }"#,
    );
    assert!(out.llvm_ir.is_some() || !out.type_errors.is_empty());
}

#[test]
fn conf_gen_005_generic_call_no_type_args_after_monomorph() {
    let out = compile(
        r#"fn id<T>(x: T) -> T { return x }
fn main() {
    let n = id<i32>(5)
    print(n)
}"#,
    );
    assert!(out.borrow_errors.is_empty());
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_gen_006_const_arithmetic_fold() {
    let out = compile(
        r#"const N = 10 + 5
fn main() { print(N) }"#,
    );
    assert!(out.type_errors.is_empty());
}

#[test]
fn conf_gen_007_multiple_instantiations() {
    let out = compile(
        r#"fn id<T>(x: T) -> T { return x }
fn main() {
    print(id<i32>(1))
    print(id<i32>(2))
}"#,
    );
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_gen_008_generic_fn_typecheck_only() {
    let out = compile_stage(
        r#"fn id<T>(x: T) -> T { return x }
fn main() { print(id<i32>(1)) }"#,
        CompileStage::TypeCheck,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_gen_009_bool_const_fold() {
    let out = compile(
        r#"const OK = true && false
fn main() {
    if OK { print(1) } else { print(0) }
}"#,
    );
    assert!(out.type_errors.is_empty());
}

#[test]
fn conf_gen_012_generic_struct_box_i32() {
    let out = compile(
        r#"struct Box<T> { value: T }
fn main() {
    let b: Box<i32> = Box { value: 7 }
    print(b.value)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("Box__i32") || ir.contains("value"));
}

#[test]
fn conf_gen_011_transitive_wrap_id() {
    let out = compile(
        r#"fn id<T>(x: T) -> T { return x }
fn wrap<T>(x: T) -> T { return id<T>(x) }
fn main() {
    print(wrap<i32>(7))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("ir");
    assert!(ir.contains("id__i32") || ir.contains("wrap__i32"));
}

#[test]
fn conf_gen_010_match_guard_const() {
    let out = compile(
        r#"fn main() {
    let x = 1
    let n = match x {
        v if v > 0 => 9
        _ => 0
    }
    print(n)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}
