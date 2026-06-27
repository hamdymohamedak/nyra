// defer runs on return — nyra test tests/nyra/defer_return_test.ny

fn cleanup_one() -> void {
    print(1)
}

fn cleanup_two() -> void {
    print(2)
}

fn with_defer_return() -> i32 {
    defer cleanup_one()
    return 0
}

fn with_defer_lifo() -> i32 {
    defer cleanup_one()
    defer cleanup_two()
    return 0
}

test fn test_defer_return_compiles() {
    assert_eq(with_defer_return(), 0)
}

test fn test_defer_lifo_compiles() {
    assert_eq(with_defer_lifo(), 0)
}
