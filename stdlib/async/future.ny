// Async runtime v2 — typed Future<T> handles + select (v1.23+).
import "../async_v1.ny"

extern fn async_promise_complete_bool(handle: i32, value: i32) -> void
extern fn async_promise_complete_ptr(handle: i32, value: string) -> void
extern fn async_await_bool(handle: i32) -> i32
extern fn async_await_ptr(handle: i32) -> string
extern fn async_poll_bool(handle: i32) -> i32
extern fn async_future_done(handle: i32) -> i32
extern fn async_future_ptr_value(handle: i32) -> string

struct Future<T> {
    handle: i32
}

struct Future_i32 {
    handle: i32
}

struct Future_bool {
    handle: i32
}

struct Future_string {
    handle: i32
}

struct SelectResult_i32 {
    index: i32
    value: i32
}

struct SelectResult_bool {
    index: i32
    value: bool
}

struct SelectResult_string {
    index: i32
    value: string
}

fn Future_new_i32() -> Future_i32 {
    return Future_i32 { handle: async_promise_new() }
}

fn Future_new_bool() -> Future_bool {
    return Future_bool { handle: async_promise_new() }
}

fn Future_new_string() -> Future_string {
    return Future_string { handle: async_promise_new() }
}

fn Future_from_handle_i32(handle: i32) -> Future_i32 {
    return Future_i32 { handle: handle }
}

fn Future_from_handle_bool(handle: i32) -> Future_bool {
    return Future_bool { handle: handle }
}

fn Future_from_handle_string(handle: i32) -> Future_string {
    return Future_string { handle: handle }
}

fn Future_complete_i32(f: Future_i32, value: i32) -> void {
    async_promise_complete(f.handle, value)
}

fn Future_complete_bool(f: Future_bool, value: bool) -> void {
    let mut v = 0
    if value {
        v = 1
    }
    async_promise_complete_bool(f.handle, v)
}

fn Future_complete_string(f: Future_string, value: string) -> void {
    async_promise_complete_ptr(f.handle, value)
}

fn Future_await_i32(f: Future_i32) -> i32 {
    return await f.handle
}

fn Future_await_bool(f: Future_bool) -> bool {
    let raw = async_await_bool(f.handle)
    if raw != 0 {
        return true
    }
    return false
}

fn Future_await_string(f: Future_string) -> string {
    return async_await_ptr(f.handle)
}

fn Future_poll_i32(f: Future_i32) -> i32 {
    return async_poll(f.handle)
}

fn Future_poll_bool(f: Future_bool) -> i32 {
    return async_poll_bool(f.handle)
}

fn Future_poll_string_done(f: Future_string) -> i32 {
    return async_future_done(f.handle)
}

fn Future_poll_string(f: Future_string) -> string {
    return async_future_ptr_value(f.handle)
}

fn Future_select2_i32(a: Future_i32, b: Future_i32) -> SelectResult_i32 {
    let running = true
    while running {
        let r0 = async_poll(a.handle)
        if r0 >= 0 {
            return SelectResult_i32 { index: 0, value: r0 }
        }
        let r1 = async_poll(b.handle)
        if r1 >= 0 {
            return SelectResult_i32 { index: 1, value: r1 }
        }
        Executor_tick(10)
    }
    return SelectResult_i32 { index: -1, value: 0 }
}

fn Future_select2_bool(a: Future_bool, b: Future_bool) -> SelectResult_bool {
    let running = true
    while running {
        let r0 = async_poll_bool(a.handle)
        if r0 >= 0 {
            let mut value = false
            if r0 != 0 {
                value = true
            }
            return SelectResult_bool { index: 0, value: value }
        }
        let r1 = async_poll_bool(b.handle)
        if r1 >= 0 {
            let mut value = false
            if r1 != 0 {
                value = true
            }
            return SelectResult_bool { index: 1, value: value }
        }
        Executor_tick(10)
    }
    return SelectResult_bool { index: -1, value: false }
}

fn Future_select2_string(a: Future_string, b: Future_string) -> SelectResult_string {
    let running = true
    while running {
        if async_future_done(a.handle) != 0 {
            return SelectResult_string { index: 0, value: async_future_ptr_value(a.handle) }
        }
        if async_future_done(b.handle) != 0 {
            return SelectResult_string { index: 1, value: async_future_ptr_value(b.handle) }
        }
        Executor_tick(10)
    }
    return SelectResult_string { index: -1, value: "" }
}
