import "stdlib/testing.ny"

fn twice(x: i32) -> i32 {
    return x + x
}

fn inferred_add(a, b) {
    return a + b
}

test fn conf_typed_fn_return() {
    assert_eq(twice(9), 18)
}

test fn conf_inferred_param_types() {
    assert_eq(inferred_add(2, 3), 5)
}
