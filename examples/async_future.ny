// Async Future<T> v2 — zero-types demo
// nyra run examples/async_future.ny

import "stdlib/async/future.ny"

async fn greet() -> string {
    let h = Executor_sleep_ms(10)
    await h
    return "Nyra async v2"
}

fn main() {
    let f = greet()
    print(await f)
}
