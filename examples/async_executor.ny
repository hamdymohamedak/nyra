// Production async executor — nyra run examples/async_executor.ny
// nyra test tests/nyra/async_executor_test.ny

import "stdlib/async_v1.ny"

async fn delayed_double(n: i32) -> i32 {
    let slept = await Executor_sleep_ms(20)
    return n * 2 + slept
}

fn main() {
    let h = delayed_double(10)
    let v = await h
    print(v)
}
