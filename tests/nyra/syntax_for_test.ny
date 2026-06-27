test fn test_for_range() {
    let mut sum = 0
    for i in 1..4 {
        sum = sum + i
    }
    assert_eq(sum, 6)
}
