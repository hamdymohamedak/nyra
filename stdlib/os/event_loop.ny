// Unified event loop — async executor + kqueue/epoll/select IO multiplexing.

import "../async_v1.ny"

extern fn io_register(fd: i32, task_id: i32) -> i32
extern fn io_unregister(fd: i32) -> i32
extern fn async_promise_new() -> i32

struct EventLoop {
    running: i32
}

fn EventLoop_new() -> EventLoop {
    return EventLoop { running: 1 }
}

fn EventLoop_tick(loop: EventLoop, timeout_ms: i32) -> i32 {
    let _ = loop
    return Executor_tick(timeout_ms)
}

fn EventLoop_poll_ms(loop: EventLoop, timeout_ms: i32) -> i32 {
    let _ = loop
    return Executor_poll_ms(timeout_ms)
}

fn EventLoop_run_until(loop: EventLoop, promise: i32, timeout_ms: i32) -> i32 {
    let _ = loop
    return Executor_run_until(promise, timeout_ms)
}

fn EventLoop_sleep_ms(loop: EventLoop, ms: i32) -> i32 {
    let _ = loop
    return Executor_sleep_ms(ms)
}

fn EventLoop_register_read(loop: EventLoop, fd: i32, promise: i32) -> i32 {
    let _ = loop
    return io_register(fd, promise)
}

fn EventLoop_unregister_fd(loop: EventLoop, fd: i32) -> i32 {
    let _ = loop
    return io_unregister(fd)
}

fn EventLoop_promise_new(loop: EventLoop) -> i32 {
    let _ = loop
    return async_promise_new()
}
