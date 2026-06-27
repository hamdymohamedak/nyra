// Async executor v1.4 — nyra test tests/nyra/async_executor_test.ny

import "stdlib/async_v1.ny"

test fn test_executor_sleep_ms() {
    let h = Executor_sleep_ms(25)
    let v = await h
    assert_eq(v, 25)
}

test fn test_spawn_await_with_executor_pump() {
    let h = async_promise_new()
    spawn {
        async_promise_complete(h, 77)
    }
    assert_eq(await h, 77)
}

test fn test_executor_run_until() {
    let h = Executor_sleep_ms(15)
    let v = Executor_run_until(h, 5000)
    assert_eq(v, 15)
}
