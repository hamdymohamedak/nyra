// env_set / env_get smoke — nyra run examples/env_set_smoke.ny
// nyra test tests/nyra/env_set_test.ny

import "stdlib/env/mod.ny"

fn main() {
    let key = "NYRA_ENV_SMOKE"
    let rc = env_set(key, "ok")
    if rc != 0 {
        print("env_set failed")
        return
    }
    let v = env_get(key)
    if strcmp(v, "ok") == 0 {
        print("env ok")
    } else {
        print("env mismatch")
    }
}

extern fn strcmp(a: string, b: string) -> i32
