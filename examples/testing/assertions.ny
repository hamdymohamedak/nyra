test fn test_assertions() {
    assert_eq(2 + 3, 5)
    assert_true(1)
    assert_bool(true)
    assert_str_eq(strcat("hel", "lo"), "hello")
}

fn main() -> void {
    test_assertions()
    print("ok")
}
