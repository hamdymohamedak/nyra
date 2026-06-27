// Async runtime v1 — executor, IO pump, timers (RFC 0005 + v1.4 executor).

extern fn async_promise_new() -> i32
extern fn async_promise_complete(handle: i32, value: i32) -> void
extern fn async_await(handle: i32) -> i32
extern fn async_poll(handle: i32) -> i32
extern fn async_sleep_ms(delay_ms: i32) -> i32
extern fn runtime_run() -> void
extern fn runtime_poll_io(timeout_ms: i32) -> i32
extern fn runtime_executor_tick(timeout_ms: i32) -> i32
extern fn runtime_executor_run_until(handle: i32, timeout_ms: i32) -> i32

struct Promise_i32 {
    handle: i32
}

fn Promise_new_i32() -> Promise_i32 {
    let h = async_promise_new()
    return Promise_i32 { handle: h }
}

fn Promise_complete_i32(p: Promise_i32, value: i32) -> void {
    async_promise_complete(p.handle, value)
}

fn Promise_await_i32(p: Promise_i32) -> i32 {
    return await p.handle
}

fn Executor_poll_once() -> void {
    runtime_run()
}

fn Executor_poll_ms(ms: i32) -> i32 {
    return runtime_poll_io(ms)
}

fn Executor_tick(timeout_ms: i32) -> i32 {
    return runtime_executor_tick(timeout_ms)
}

fn Executor_run_until(handle: i32, timeout_ms: i32) -> i32 {
    return runtime_executor_run_until(handle, timeout_ms)
}

fn Executor_sleep_ms(ms: i32) -> i32 {
    return async_sleep_ms(ms)
}
