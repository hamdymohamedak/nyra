// Future<T> + select — zero-types smoke test
// nyra test tests/nyra/async_future_test.ny

import "stdlib/async/future.ny"

async fn give_i32() -> i32 {
    return 20
}

test fn test_future_async_fn_i32() {
    let f = give_i32()
    assert_eq(await f, 20)
}

test fn test_future_manual_i32() {
    let h = async_promise_new()
    let f = Future_from_handle_i32(h)
    spawn {
        async_promise_complete(h, 55)
    }
    assert_eq(await f, 55)
}

test fn test_future_bool() {
    let h = async_promise_new()
    let f = Future_from_handle_bool(h)
    spawn {
        async_promise_complete_bool(h, 1)
    }
    let v = await f
    if !v {
        assert_eq(1, 0)
    }
}

test fn test_future_string() {
    let h = async_promise_new()
    let f = Future_from_handle_string(h)
    spawn {
        async_promise_complete_ptr(h, "hello")
    }
    let s = await f
    if s != "hello" {
        assert_eq(1, 0)
    }
}
