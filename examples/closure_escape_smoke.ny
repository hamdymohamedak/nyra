fn make_adder(delta: i32) -> fn(i32) -> i32 {
    return (x) => x + delta
}

fn main() {
    let add5 = make_adder(5)
    print(add5(10))
}
