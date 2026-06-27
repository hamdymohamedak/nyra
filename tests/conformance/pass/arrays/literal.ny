import "stdlib/testing.ny"

test fn conf_array_literal_len() {
    let xs = [1, 2, 3]
    assert_eq(xs.len(), 3)
}

test fn conf_array_index() {
    let xs = [10, 20, 30]
    assert_eq(xs[0], 10)
    assert_eq(xs[1], 20)
    assert_eq(xs[2], 30)
}
