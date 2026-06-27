import "stdlib/testing.ny"

test fn conf_ternary_basic() {
    let pick = 3 > 1 ? 42 : 0
    assert_eq(pick, 42)
}

test fn conf_ternary_with_comparison() {
    let x = 10
    let label = x > 5 ? 1 : 0
    assert_eq(label, 1)
}

test fn conf_nested_ternary_right_assoc() {
    let x = false ? 1 : true ? 2 : 3
    assert_eq(x, 2)
}
