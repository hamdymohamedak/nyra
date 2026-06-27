// Async state-machine: await inside while — v1.7
// nyra test tests/nyra/async_state_machine_while_test.ny

import "stdlib/async_v1.ny"

async fn count_down() -> i32 {
    mut n = 3
    while n > 0 {
        let _ = await Executor_sleep_ms(2)
        n = n - 1
    }
    return n
}

test fn test_await_in_while() {
    assert_eq(await count_down(), 0)
}
