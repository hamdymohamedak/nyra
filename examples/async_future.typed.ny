// Async Future<T> v2 — typed demo
// nyra run examples/async_future.typed.ny

import "stdlib/async/future.ny"

async fn greet() -> string {
    let h: i32 = Executor_sleep_ms(10)
    await h
    return "Nyra async v2"
}

fn main() {
    let f: Future_string = greet()
    let msg: string = await f
    print(msg)
}
