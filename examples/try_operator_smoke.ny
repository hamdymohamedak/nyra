// Result/Option propagation with `?` — nyra run examples/try_operator_smoke.ny
// nyra test tests/nyra/result_propagate_test.ny

enum Result_i32_i32 {
    Ok(i32),
    Err(i32),
}

fn step(n: i32) -> Result_i32_i32 {
    if n < 0 {
        return Result_i32_i32.Err(1)
    }
    return Result_i32_i32.Ok(n)
}

fn run_pipeline() -> Result_i32_i32 {
    let a = step(1)?
    let b = step(a + 1)?
    let c = step(b * 2)?
    return Result_i32_i32.Ok(c)
}

fn main() {
    let n = match run_pipeline() {
        Result_i32_i32.Ok(v) => v
        Result_i32_i32.Err(_e) => 0
    }
    print(n)
}
