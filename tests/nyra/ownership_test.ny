test fn test_copy_i32() {
    let a = 7
    let b = a
    assert_eq(a, 7)
    assert_eq(b, 7)
}

test fn test_const_fold() {
    assert_eq(2 + 3, 5)
}
