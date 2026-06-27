test fn test_while_loop() {
    let mut i = 0
    let mut sum = 0
    while i < 5 {
        sum = sum + i
        i = i + 1
    }
    assert_eq(sum, 10)
}
