import "stdlib/testing.ny"

test fn conf_string_len() {
    let s = "abc"
    assert_eq(s.len(), 3)
}

test fn conf_string_concat() {
    let a = "hel"
    let b = "lo"
    let s = a + b
    assert_eq(s.len(), 5)
}

test fn conf_empty_string() {
    let s = ""
    assert_eq(s.len(), 0)
}
