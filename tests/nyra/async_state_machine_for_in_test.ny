// Async state-machine: await inside for-in over fixed array — v1.8
// nyra test tests/nyra/async_state_machine_for_in_test.ny

import "stdlib/async_v1.ny"

async fn walk() -> i32 {
    let arr = [1, 2, 3]
    for n in arr {
        let _ = await Executor_sleep_ms(n)
    }
    return 3
}

test fn test_await_in_for_in_array() {
    assert_eq(await walk(), 3)
}
