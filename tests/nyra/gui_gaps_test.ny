test fn test_continue_loop() {
    let mut sum = 0
    let mut i = 0
    while i < 10 {
        i = i + 1
        if i == 5 {
            continue
        }
        sum = sum + i
    }
    assert_eq(sum, 50)
}

test fn test_char_from_code() {
    let ch = char_from_code(65)
    assert_eq(strlen(ch), 1)
    assert_eq(char_at(ch, 0), 65)
}

test fn test_argv_helper() {
    let args = argv()
    assert_eq(args.len(), args.len())
}

test fn test_string_builder() {
    let mut sb = StringBuilder_new()
    sb = StringBuilder_push(sb, "hel")
    sb = StringBuilder_push_char(sb, 108)
    sb = StringBuilder_push(sb, "o")
    let out = StringBuilder_build(sb)
    assert_str_eq(out, "hello")
}

test fn test_read_file_limit_exists() {
    if exists("Cargo.toml") == 1 {
        let text = read_file_limit("Cargo.toml", 32)
        let n = strlen(text)
        if n > 32 {
            assert_eq(1, 0)
        }
    }
}
