// Enum payloads + pattern matching tests
// nyra test tests/nyra/enum_payload_match_test.ny

enum Option_i32 {
    None,
    Some(i32),
}

enum Result_i32_i32 {
    Ok(i32),
    Err(i32),
}

test fn test_payload_bind_and_match() {
    let x = Option_i32.Some(10)
    let n = match x {
        Option_i32.Some(v) => v + 1,
        Option_i32.None => 0,
    }
    assert_eq(n, 11)
}

test fn test_match_guard_on_payload() {
    let r = Result_i32_i32.Ok(5)
    let n = match r {
        Result_i32_i32.Ok(v) if v > 3 => v * 2,
        Result_i32_i32.Ok(_v) => 0,
        Result_i32_i32.Err(e) => e,
    }
    assert_eq(n, 10)
}

test fn test_match_arm_trailing_comma() {
    let x = Option_i32.Some(4)
    let n = match x {
        Option_i32.Some(v) => v * 3,
        Option_i32.None => 0,
    }
    assert_eq(n, 12)
}

enum Option<T> {
    None,
    Some(T),
}

fn option_double(x: Option<i32>) -> i32 {
    return match x {
        Option.Some(v) => v * 2,
        Option.None => 0,
    }
}

test fn test_match_generic_option_param() {
    assert_eq(option_double(Option.Some(21)), 42)
}

enum Result<T, E> {
    Ok(T),
    Err(E),
}

fn result_take(r: Result<i32, i32>) -> i32 {
    return match r {
        Result.Ok(v) => v,
        Result.Err(e) => e,
    }
}

test fn test_generic_result_ok_at_call_site() {
    assert_eq(result_take(Result.Ok(7)), 7)
}
