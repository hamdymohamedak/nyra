module tests.generics_option_modules

enum Option_i32 {
    None,
    Some(i32),
}

enum Option<T> {
    None,
    Some(T),
}

fn id_i32(x: i32) -> i32 {
    return x
}

fn unwrap_i32(opt: Option_i32, default: i32) -> i32 {
    return match opt {
        Option_i32.Some(v) => v
        Option_i32.None => default
    }
}

fn double_opt(x: Option<i32>) -> i32 {
    return match x {
        Option.Some(v) => v * 2
        Option.None => 0
    }
}

fn main() -> i32 {
    assert_eq(id_i32(42), 42)
    let some = Option_i32.Some(7)
    let none = Option_i32.None
    assert_eq(unwrap_i32(some, 0), 7)
    assert_eq(unwrap_i32(none, 9), 9)
    assert_eq(double_opt(Option.Some(21)), 42)
    let empty = Option.None
    let fallback = empty ?? 99
    assert_eq(fallback, 99)
    return 0
}
