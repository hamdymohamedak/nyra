// Macro expansion smoke — nyra test tests/nyra/macro_expand_test.ny

macro add(a, b) { a + b }

test fn test_two_param_macro() {
    let n = add(2, 3)
    assert_eq(n, 5)
}

macro dbl(x) { x + x }

test fn test_macro_call() {
    let n = dbl(4)
    assert_eq(n, 8)
}
