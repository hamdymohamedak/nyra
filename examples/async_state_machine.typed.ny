// Linear async state-machine — v1.6 (explicit types)
// nyra run examples/async_state_machine.typed.ny

import "stdlib/async_v1.ny"

async fn chain() -> i32 {
    let _: i32 = await Executor_sleep_ms(5)
    let _: i32 = await Executor_sleep_ms(5)
    return 100
}

fn main() -> void {
    let h: Future_i32 = chain()
    let v: i32 = await h
    print(v)
}
