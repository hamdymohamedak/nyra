import "stdlib/testing.ny"

test fn conf_let_i32_literal() {
    let x = 5
    assert_eq(x, 5)
}

test fn conf_let_rebind() {
    let mut n = 1
    n = 10
    assert_eq(n, 10)
}
