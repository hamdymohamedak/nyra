import "stdlib/testing.ny"

test fn conf_bool_truth() {
    assert_eq(1, 1)
    assert_ne(0, 1)
    assert_true(1)
}

test fn conf_comparison_ops() {
    assert_bool(3 == 3)
    assert_bool(3 != 4)
    assert_bool(2 < 5)
    assert_bool(5 > 2)
    assert_bool(4 <= 4)
    assert_bool(6 >= 6)
}
