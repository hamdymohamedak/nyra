// Result propagation with `?` — compare with the verbose match version in result_propagate_verbose.ny
// Runnable: nyra run examples/result_propagate_question.ny

enum Result_i32_i32 {
    Ok(i32),
    Err(i32),
}

fn step(n: i32) -> Result_i32_i32 {
    return Result_i32_i32.Ok(n)
}

fn pipeline() -> Result_i32_i32 {
    let v1 = step(1)?
    let v2 = step(v1 + 1)?
    return Result_i32_i32.Ok(v2 * 2)
}

fn main() {
    let n = match pipeline() {
        Result_i32_i32.Ok(v) => v
        Result_i32_i32.Err(e) => e
    }
    print(n)
}
