import "stdlib/testing.ny"
import "stdlib/env/mod.ny"

test fn test_env_set_get() {
    let key = "NYRA_TEST_ENV_KEY"
    let rc = env_set(clone key, "42")
    assert_eq(rc, 0)
    let v = env_get(key)
    assert_str_eq(v, "42")
}

test fn test_env_has() {
    let key = "NYRA_TEST_ENV_HAS"
    env_set(clone key, "1")
    assert_eq(env_has(key), 1)
}
