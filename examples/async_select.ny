// async select demo — zero-types
// nyra run examples/async_select.ny

import "stdlib/async/future.ny"

fn main() {
    let a = Executor_sleep_ms(30)
    let b = Executor_sleep_ms(5)
    let picked = Future_select2_i32(
        Future_from_handle_i32(a),
        Future_from_handle_i32(b)
    )
    print(picked.index)
    print(picked.value)
}
