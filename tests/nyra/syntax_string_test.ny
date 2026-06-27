test fn test_string_methods() {
    let s = "  nyra  "
    let t = s.trim()
    print(t)
    assert_eq(t.len(), 4)
    let u = s.to_upper()
    assert_eq(u.len(), 8)
    let parts = "a,b,c".split(",")
    assert_eq(parts.len(), 3)
}
