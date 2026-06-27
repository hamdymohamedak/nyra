import "stdlib/testing.ny"

test fn conf_add() {
    assert_eq(2 + 3, 5)
}

test fn conf_sub_mul_div_mod() {
    assert_eq(10 - 4, 6)
    assert_eq(3 * 4, 12)
    assert_eq(8 / 2, 4)
    assert_eq(7 % 3, 1)
}
