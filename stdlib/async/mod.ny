// Async MVP — import this module to use promises, await, and spawn together.
import "../async.ny"

// Re-export runtime entry points (also available as builtins when codegen sees them).
// Pattern:
//   let h = async_promise_new()
//   spawn { async_promise_complete(h, 42) }
//   print(await h)

fn async_promise() -> i32 {
    return async_promise_new()
}

fn async_complete(handle: i32, value: i32) -> void {
    async_promise_complete(handle, value)
}

fn async_poll(handle: i32) -> i32 {
    return async_poll(handle)
}

fn async_run_once() -> void {
    runtime_run()
}
