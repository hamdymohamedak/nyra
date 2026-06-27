import "stdlib/testing.ny"

test fn conf_while_count() {
    let mut i = 0
    while i < 5 {
        i = i + 1
    }
    assert_eq(i, 5)
}

test fn conf_for_range_sum() {
    let mut sum = 0
    for i in 1..4 {
        sum = sum + i
    }
    assert_eq(sum, 6)
}
