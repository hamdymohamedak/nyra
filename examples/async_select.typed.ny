// async select demo — typed
// nyra run examples/async_select.typed.ny

import "stdlib/async/future.ny"

fn main() {
    let a: i32 = Executor_sleep_ms(30)
    let b: i32 = Executor_sleep_ms(5)
    let picked: SelectResult_i32 = Future_select2_i32(
        Future_from_handle_i32(a),
        Future_from_handle_i32(b)
    )
    print(picked.index)
    print(picked.value)
}
