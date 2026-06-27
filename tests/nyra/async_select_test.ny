// async select — zero-types
// nyra test tests/nyra/async_select_test.ny

import "stdlib/async/future.ny"

test fn test_select2_i32_first() {
    let ha = async_promise_new()
    let hb = async_promise_new()
    let a = Future_from_handle_i32(ha)
    let b = Future_from_handle_i32(hb)
    spawn {
        async_promise_complete(ha, 11)
    }
    spawn {
        async_promise_complete(hb, 22)
    }
    let picked = Future_select2_i32(a, b)
    assert_eq(picked.index, 0)
    assert_eq(picked.value, 11)
}

test fn test_select2_i32_sleep() {
    let fast = Executor_sleep_ms(5)
    let slow = Executor_sleep_ms(80)
    let f_fast = Future_from_handle_i32(fast)
    let f_slow = Future_from_handle_i32(slow)
    let picked = Future_select2_i32(f_fast, f_slow)
    assert_eq(picked.index, 0)
    assert_eq(picked.value, 5)
}
