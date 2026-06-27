// Async fn desugar (spawn + promise handle) — v1.5
// nyra test tests/nyra/async_spawn_desugar_test.ny

import "stdlib/async_v1.ny"

async fn make_value() -> i32 {
    return 99
}

async fn delayed_sum(a: i32, b: i32) -> i32 {
    let _ = await Executor_sleep_ms(5)
    return a + b
}

test fn test_async_fn_returns_handle() {
    let h = make_value()
    assert_eq(await h, 99)
}

test fn test_async_fn_with_sleep() {
    let h = delayed_sum(10, 32)
    assert_eq(await h, 42)
}
