import "../testing.ny"

fn quick_check_i32(pred: fn(i32) -> i32, value: i32) -> void {
    if pred(value) == 0 {
        test_fail("quick_check_i32 failed")
    }
}

fn quick_check_eq_i32(actual: i32, expected: i32) -> void {
    assert_eq(actual, expected)
}

fn quick_check_range_i32(start: i32, end: i32, pred: fn(i32) -> i32) -> void {
    let mut i = start
    while i < end {
        quick_check_i32(pred, i)
        i = i + 1
    }
}
