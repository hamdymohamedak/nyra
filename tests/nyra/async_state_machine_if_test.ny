// Async state-machine: await inside if — v1.7
// nyra test tests/nyra/async_state_machine_if_test.ny

import "stdlib/async_v1.ny"

async fn pick(high: bool) -> i32 {
    if high {
        let _ = await Executor_sleep_ms(3)
        return 10
    } else {
        let _ = await Executor_sleep_ms(3)
        return 1
    }
}

test fn test_await_in_if_then() {
    assert_eq(await pick(true), 10)
}

test fn test_await_in_if_else() {
    assert_eq(await pick(false), 1)
}
