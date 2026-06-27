// Async state-machine: await inside spawn and unsafe — v1.9
// nyra test tests/nyra/async_state_machine_spawn_test.ny

import "stdlib/async_v1.ny"

async fn with_unsafe() -> i32 {
    unsafe {
        let _ = await Executor_sleep_ms(5)
    }
    return 7
}

async fn with_spawn() -> i32 {
    spawn {
        let _ = await Executor_sleep_ms(3)
    }
    let _ = await Executor_sleep_ms(5)
    return 7
}

test fn test_await_in_unsafe() {
    assert_eq(await with_unsafe(), 7)
}

test fn test_await_in_spawn() {
    assert_eq(await with_spawn(), 7)
}
