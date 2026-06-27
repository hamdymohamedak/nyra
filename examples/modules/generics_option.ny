module examples.modules_generics_option

enum Option<T> {
    None,
    Some(T),
}

fn double(x: Option<i32>) -> i32 {
    return match x {
        Option.Some(v) => v * 2
        Option.None => 0
    }
}

fn main() -> i32 {
    print(double(Option.Some(21)))
    print(double(Option.None))
    return 0
}
