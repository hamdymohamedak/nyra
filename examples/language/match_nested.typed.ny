// Nested match: Result.Ok(Some(x)) without repeating the inner enum name.
enum Option_i32 {
    None
    Some(i32)
}

enum Result_Opt {
    Ok(Option_i32)
    Fail(Option_i32)
}

fn main() {
    let r: Result_Opt = Result_Opt.Ok(Option_i32.Some(7))
    let n: i32 = match r {
        Result_Opt.Ok(Some(v)) => v
        Result_Opt.Ok(Option_i32.None) => -1
        Result_Opt.Fail(_) => -2
    }
    print(n)
}
