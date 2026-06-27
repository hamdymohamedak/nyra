// Block comments (/* ... */) — Core lexer feature.

test fn test_block_comment_inline() {
    let x = 1 /* add one */ + 1
    assert_eq(x, 2)
}

test fn test_block_comment_multiline() {
    /*
     * Header comment
     * spanning lines
     */
    let n = 10
    assert_eq(n, 10)
}

test fn test_block_comment_between_tokens() {
    let a = 5
    let b = /* sep */ 3
    assert_eq(a + b, 8)
}
