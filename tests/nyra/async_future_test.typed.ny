// Future<T> + select — typed smoke test
// nyra test tests/nyra/async_future_test.typed.ny

import "stdlib/async/future.ny"

async fn give_i32() -> i32 {
    return 20
}

test fn test_future_async_fn_i32() {
    let f: Future_i32 = give_i32()
    let v: i32 = await f
    assert_eq(v, 20)
}

test fn test_future_manual_i32() {
    let h: i32 = async_promise_new()
    let f: Future_i32 = Future_from_handle_i32(h)
    spawn {
        async_promise_complete(h, 55)
    }
    let v: i32 = await f
    assert_eq(v, 55)
}

test fn test_future_bool() {
    let h: i32 = async_promise_new()
    let f: Future_bool = Future_from_handle_bool(h)
    spawn {
        async_promise_complete_bool(h, 1)
    }
    let v: bool = await f
    if !v {
        assert_eq(1, 0)
    }
}

test fn test_future_string() {
    let h: i32 = async_promise_new()
    let f: Future_string = Future_from_handle_string(h)
    spawn {
        async_promise_complete_ptr(h, "hello")
    }
    let s: string = await f
    if s != "hello" {
        assert_eq(1, 0)
    }
}
