// Async state-machine with Future<bool> (typed) — v1.27
import "stdlib/async/future.ny"

async fn flip() -> bool {
    let h = async_promise_new()
    spawn {
        async_promise_complete_bool(h, 1)
    }
    let f: Future_bool = Future_from_handle_bool(h)
    return await f
}

test fn test_state_machine_bool_return() {
    let f: Future_bool = flip()
    let v: bool = await f
    if !v {
        assert_eq(1, 0)
    }
}
