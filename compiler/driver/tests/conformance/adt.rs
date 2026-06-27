//! Conformance tests: ADT enums with payloads (CONF-ADT-*).

use crate::common::compile;

#[test]
fn conf_adt_001_option_some_construct_and_match() {
    let out = compile(
        r#"enum Option_i32 {
    None,
    Some(i32),
}
fn main() {
    let x = Option_i32.Some(42)
    let n = match x {
        Option_i32.Some(v) => v
        Option_i32.None => 0
    }
    print(n)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_adt_002_option_none_unit() {
    let out = compile(
        r#"enum Option_i32 {
    None,
    Some(i32),
}
fn main() {
    let x = Option_i32.None
    let n = match x {
        Option_i32.Some(v) => v
        Option_i32.None => 99
    }
    print(n)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_adt_003_result_verbose_propagate_needs_repeated_match() {
    let out = compile(
        r#"enum Result_i32_i32 {
    Ok(i32),
    Err(i32),
}
fn main() {
    let v1 = match Result_i32_i32.Ok(1) {
        Result_i32_i32.Ok(x) => x
        Result_i32_i32.Err(_e) => 0
    }
    let v2 = match Result_i32_i32.Ok(v1 + 1) {
        Result_i32_i32.Ok(x) => x
        Result_i32_i32.Err(_e) => 0
    }
    let v3 = match Result_i32_i32.Ok(v2 * 2) {
        Result_i32_i32.Ok(x) => x
        Result_i32_i32.Err(_e) => 0
    }
    print(v3)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some(), "Result propagate should lower to LLVM IR");
    let ir = out.llvm_ir.unwrap();
    assert!(
        ir.contains("match.body") || ir.contains("switch") || ir.contains("icmp"),
        "expected match lowering for chained Result steps:\n{ir}"
    );
}

#[test]
fn conf_adt_004_result_question_operator_propagates_err() {
    let out = compile(
        r#"enum Result_i32_i32 {
    Ok(i32),
    Err(i32),
}
fn step(n: i32) -> Result_i32_i32 {
    return Result_i32_i32.Ok(n)
}
fn pipeline() -> Result_i32_i32 {
    let a = step(1)?
    let b = step(a + 1)?
    return Result_i32_i32.Ok(b * 2)
}
fn main() {
    let n = match pipeline() {
        Result_i32_i32.Ok(v) => v
        Result_i32_i32.Err(e) => e
    }
    print(n)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("? should lower to LLVM IR");
    assert!(
        ir.contains("ret %Result_i32_i32") || ir.contains("ret i32"),
        "expected early return on Err in desugared ? pipeline"
    );
}

#[test]
fn conf_adt_005_match_guard_with_payload() {
    let out = compile(
        r#"enum Result_i32_i32 { Ok(i32), Err(i32) }
fn main() {
    let r = Result_i32_i32.Ok(5)
    let n = match r {
        Result_i32_i32.Ok(v) if v > 3 => v * 2
        Result_i32_i32.Ok(_v) => 0
        Result_i32_i32.Err(e) => e
    }
    print(n)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_adt_006_match_arm_trailing_comma() {
    let out = compile(
        r#"enum Option_i32 { None, Some(i32) }
fn main() {
    let x = Option_i32.Some(4)
    let n = match x {
        Option_i32.Some(v) => v * 3,
        Option_i32.None => 0,
    }
    print(n)
}"#,
    );
    assert!(out.parser_errors.is_empty(), "{:?}", out.parser_errors);
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
}

#[test]
fn conf_adt_007_match_generic_option_param() {
    let out = compile(
        r#"enum Option<T> {
    None,
    Some(T),
}
fn option_double(x: Option<i32>) -> i32 {
    return match x {
        Option.Some(v) => v * 2,
        Option.None => 0,
    }
}
fn main() {
    print(option_double(Option.Some(21)))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    let ir = out.llvm_ir.expect("generic Option param match should lower");
    assert!(
        ir.contains("Option__i32") && (ir.contains("icmp") || ir.contains("load i32")),
        "expected tag load on Option__i32 struct, not raw ptr icmp:\n{ir}"
    );
}

#[test]
fn conf_adt_008_generic_result_ok_at_call_site() {
    let out = compile(
        r#"enum Result<T, E> {
    Ok(T),
    Err(E),
}
fn take(r: Result<i32, i32>) -> i32 {
    return match r {
        Result.Ok(v) => v,
        Result.Err(e) => e,
    }
}
fn main() {
    print(take(Result.Ok(7)))
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_adt_009_let_match_with_try() {
    let out = compile(
        r#"enum Result_i32_i32 { Ok(i32), Err(i32) }
fn ok_step(n: i32) -> Result_i32_i32 { return Result_i32_i32.Ok(n) }
fn pipeline() -> Result_i32_i32 {
    let n = match Result_i32_i32.Ok(1) {
        Result_i32_i32.Ok(v) => ok_step(v)?
        Result_i32_i32.Err(e) => e
    }
    return Result_i32_i32.Ok(n)
}
fn main() {
    let v = match pipeline() {
        Result_i32_i32.Ok(n) => n
        Result_i32_i32.Err(e) => e
    }
    print(v)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}

#[test]
fn conf_adt_010_let_match_with_try_void_fn() {
    let out = compile(
        r#"enum Result_i32_i32 { Ok(i32), Err(i32) }
fn ok_step(n: i32) -> Result_i32_i32 { return Result_i32_i32.Ok(n) }
fn main() {
    let n = match Result_i32_i32.Ok(1) {
        Result_i32_i32.Ok(v) => ok_step(v)?
        Result_i32_i32.Err(e) => e
    }
    print(n)
}"#,
    );
    assert!(out.type_errors.is_empty(), "{:?}", out.type_errors);
    assert!(out.llvm_ir.is_some());
}
