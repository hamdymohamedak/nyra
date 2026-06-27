import "stdlib/testing.ny"

fn add(a: i32, b: i32) -> i32 {
    return a + b
}

fn double(x: i32) -> i32 {
    return x + x
}

fn inferred_add(a, b) {
    return a + b
}

test fn conf_fn_params_and_return() {
    assert_eq(add(10, 20), 30)
    assert_eq(double(7), 14)
}

test fn conf_fn_inferred_params() {
    assert_eq(inferred_add(2, 3), 5)
}
