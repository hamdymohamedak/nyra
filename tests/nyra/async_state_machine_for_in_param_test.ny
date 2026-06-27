// Async state-machine: await inside for-in over array parameter — v1.9
// nyra test tests/nyra/async_state_machine_for_in_param_test.ny

import "stdlib/async_v1.ny"

async fn walk(arr: [i32; 2]) -> i32 {
    for n in arr {
        let _ = await Executor_sleep_ms(n)
    }
    return 2
}

test fn test_await_in_for_in_param() {
    assert_eq(await walk([1, 2]), 2)
}
