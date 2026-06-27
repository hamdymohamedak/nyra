// Async fn desugar — explicit types
// nyra run examples/async_spawn.typed.ny

import "stdlib/async_v1.ny"

async fn compute() -> i32 {
    return 42
}

fn main() -> void {
    let h: Future_i32 = compute()
    print(await h)
}
