// Linear async state-machine — v1.6 (zero-types)
// nyra run examples/async_state_machine.ny

import "stdlib/async_v1.ny"

async fn chain() -> i32 {
    let _ = await Executor_sleep_ms(5)
    let _ = await Executor_sleep_ms(5)
    return 100
}

fn main() {
    let h = chain()
    print(await h)
}
