fn main() {
    assert_str_eq("foo".replace("o", "0"), "f00")
    assert_str_eq("A S K".replace(" ", "_"), "A_S_K")
    assert_str_eq("foo".replacen("o", "0", 1), "f0o")
    assert_str_eq("A S K".replacen(" ", "_", 1), "A_S K")
    assert_str_eq("aaa".replacen("a", "b", 2), "bba")
}
