fn test_sha256_hello() -> void {
    let digest = sha256("hello")
    assert_str_eq(digest, "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
}

fn test_sha256_empty() -> void {
    let digest = sha256("")
    assert_str_eq(digest, "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
}

fn main() -> i32 {
    test_sha256_hello()
    test_sha256_empty()
    return 0
}
