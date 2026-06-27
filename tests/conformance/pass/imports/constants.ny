import "stdlib/testing.ny"

// Resolved via tests/conformance/fixtures/import_smoke/ project layout in runner.
// Standalone smoke: re-export pattern with inline const (import fixture tested separately).

const CONF_LOCAL_ANSWER = 42

test fn conf_local_const() {
    assert_eq(CONF_LOCAL_ANSWER, 42)
}
