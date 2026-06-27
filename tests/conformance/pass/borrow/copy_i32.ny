import "stdlib/testing.ny"

test fn conf_i32_copy_after_bind() {
    let a = 7
    let b = a
    assert_eq(a, 7)
    assert_eq(b, 7)
}

test fn conf_mut_borrow_read_while_alive() {
    let mut n = 1
    let r = n
    assert_eq(r + n, 2)
}
