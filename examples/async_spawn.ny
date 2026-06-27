// Async fn desugar — call returns handle immediately (v1.5)
// nyra run examples/async_spawn.ny

import "stdlib/async_v1.ny"

async fn compute() -> i32 {
    return 42
}

fn main() {
    let h = compute()
    print(await h)
}
