// Production async executor — typed — nyra run examples/async_executor.typed.ny

import "stdlib/async_v1.ny"

async fn delayed_double(n: i32) -> i32 {
    let slept = await Executor_sleep_ms(20)
    return n * 2 + slept
}

fn main() -> void {
    let h: Future_i32 = delayed_double(10)
    let v: i32 = await h
    print(v)
}
