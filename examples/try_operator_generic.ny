// Generic Result<T,E> with `?` — auto-prelude monomorphizes Result<i32,i32>.
// nyra run examples/try_operator_generic.ny

fn step(n: i32) -> Result<i32, i32> {
    return Result.Ok(n)
}

fn fail_if_zero(n: i32) -> Result<i32, i32> {
    if n == 0 {
        return Result.Err(1)
    }
    return Result.Ok(n)
}

fn main() -> Result<i32, i32> {
    let a = step(1)?
    let b = step(a + 1)?
    let z = fail_if_zero(b)?
    print(step(z)?)
    let r = step(z + 1)
    return match r {
        Result.Ok(x) => step(x)?
        Result.Err(e) => Result.Err(e)
    }
}
