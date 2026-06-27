// Async runtime — import for explicit dependency on async symbols.
extern fn async_promise_new() -> i32
extern fn async_promise_complete(handle: i32, value: i32) -> void
extern fn async_await(handle: i32) -> i32
extern fn async_poll(handle: i32) -> i32
extern fn async_run(result: i32) -> i32
extern fn runtime_run() -> void
