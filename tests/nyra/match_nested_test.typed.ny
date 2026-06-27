// Nested enum match patterns — peel payload enums inside a variant arm.

enum Option_i32 {
    None
    Some(i32)
}

enum Result_Opt {
    Ok(Option_i32)
    Fail(Option_i32)
}

fn unwrap_ok_some(r: Result_Opt) -> i32 {
    return match r {
        Result_Opt.Ok(Some(x)) => x
        Result_Opt.Ok(Option_i32.None) => 0
        Result_Opt.Fail(_) => -1
    }
}

fn main() {
    let a: Result_Opt = Result_Opt.Ok(Option_i32.Some(42))
    print(unwrap_ok_some(a))
    let b: Result_Opt = Result_Opt.Ok(Option_i32.None)
    print(unwrap_ok_some(b))
    let c: Result_Opt = Result_Opt.Fail(Option_i32.None)
    print(unwrap_ok_some(c))
}
