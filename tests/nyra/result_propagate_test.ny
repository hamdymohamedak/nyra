// Result/Option propagation — `?` operator on Result and Option.

enum Result_i32_i32 {
    Ok(i32),
    Err(i32),
}

enum Option_i32 {
    None,
    Some(i32),
}

fn ok_step(n: i32) -> Result_i32_i32 {
    return Result_i32_i32.Ok(n)
}

fn some_step(n: i32) -> Option_i32 {
    if n == 0 {
        return Option_i32.None
    }
    return Option_i32.Some(n)
}

test fn test_result_question_operator() {
    let v = match pipeline_with_question() {
        Result_i32_i32.Ok(x) => x
        Result_i32_i32.Err(_e) => 0
    }
    assert_eq(v, 4)
}

fn pipeline_with_question() -> Result_i32_i32 {
    let a = ok_step(1)?
    let b = ok_step(a + 1)?
    return Result_i32_i32.Ok(b * 2)
}

test fn test_result_question_err_short_circuits() {
    let code = match run_fail() {
        Result_i32_i32.Ok(_v) => 0
        Result_i32_i32.Err(e) => e
    }
    assert_eq(code, 9)
}

fn fail_step() -> Result_i32_i32 {
    return Result_i32_i32.Err(9)
}

fn run_fail() -> Result_i32_i32 {
    let _ = fail_step()?
    return Result_i32_i32.Ok(0)
}

test fn test_option_question_operator() {
    let v = match option_pipeline() {
        Option_i32.Some(n) => n
        Option_i32.None => 0
    }
    assert_eq(v, 6)
}

fn option_pipeline() -> Option_i32 {
    let a = some_step(2)?
    let b = some_step(a + 1)?
    return Option_i32.Some(b * 2)
}

test fn test_result_verbose_propagate_no_question_mark() {
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
    assert_eq(v3, 4)
}

test fn test_result_err_arm() {
    let code = match Result_i32_i32.Err(7) {
        Result_i32_i32.Ok(_x) => 0
        Result_i32_i32.Err(e) => e
    }
    assert_eq(code, 7)
}

test fn test_result_nested_match_propagate() {
    let n = match Result_i32_i32.Ok(1) {
        Result_i32_i32.Ok(v1) => match Result_i32_i32.Ok(v1 + 1) {
            Result_i32_i32.Ok(v2) => match Result_i32_i32.Ok(v2 * 2) {
                Result_i32_i32.Ok(v3) => v3
                Result_i32_i32.Err(_e) => 0
            }
            Result_i32_i32.Err(_e) => 0
        }
        Result_i32_i32.Err(_e) => 0
    }
    assert_eq(n, 4)
}

test fn test_result_try_in_print_arg() {
    let code = match run_print_try() {
        Result_i32_i32.Ok(v) => v
        Result_i32_i32.Err(e) => e
    }
    assert_eq(code, 3)
}

fn run_print_try() -> Result_i32_i32 {
    print(ok_step(1)?)
    return Result_i32_i32.Ok(3)
}

test fn test_result_try_in_return_match_arm() {
    let v = match run_return_match_try() {
        Result_i32_i32.Ok(n) => n
        Result_i32_i32.Err(_e) => 0
    }
    assert_eq(v, 2)
}

fn run_return_match_try() -> Result_i32_i32 {
    let res = ok_step(1)
    return match res {
        Result_i32_i32.Ok(x) => ok_step(x + 1)?
        Result_i32_i32.Err(e) => Result_i32_i32.Err(e)
    }
}

test fn test_result_try_in_let_match() {
    let v = match run_let_match_try() {
        Result_i32_i32.Ok(n) => n
        Result_i32_i32.Err(_e) => 0
    }
    assert_eq(v, 1)
}

test fn test_result_try_in_let_match_void() {
    assert_eq(let_match_try_void(), 1)
}

fn run_let_match_try() -> Result_i32_i32 {
    let n = match Result_i32_i32.Ok(1) {
        Result_i32_i32.Ok(v) => ok_step(v)?
        Result_i32_i32.Err(e) => e
    }
    return Result_i32_i32.Ok(n)
}

fn let_match_try_void() -> i32 {
    let n = match Result_i32_i32.Ok(1) {
        Result_i32_i32.Ok(v) => ok_step(v)?
        Result_i32_i32.Err(e) => e
    }
    return n
}
