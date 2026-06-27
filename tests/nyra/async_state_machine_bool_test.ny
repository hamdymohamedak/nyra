// Async state-machine with Future<bool> — v1.27
// nyra test tests/nyra/async_state_machine_bool_test.ny

import "stdlib/async/future.ny"

async fn flip() -> bool {
    let h = async_promise_new()
    spawn {
        async_promise_complete_bool(h, 1)
    }
    let f = Future_from_handle_bool(h)
    return await f
}

test fn test_state_machine_bool_return() {
    let f = flip()
    let v = await f
    if !v {
        assert_eq(1, 0)
    }
}
