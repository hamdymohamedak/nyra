// Linear async state-machine desugar — v1.6
// nyra test tests/nyra/async_state_machine_test.ny

import "stdlib/async_v1.ny"

async fn chain_sleep() -> i32 {
    let _ = await Executor_sleep_ms(3)
    let _ = await Executor_sleep_ms(3)
    return 42
}

async fn sleep_then_value() -> i32 {
    let _ = await Executor_sleep_ms(5)
    return 99
}

test fn test_two_linear_awaits() {
    let h = chain_sleep()
    assert_eq(await h, 42)
}

test fn test_single_await_still_works() {
    let h = sleep_then_value()
    assert_eq(await h, 99)
}
