// Nested struct JSON synthesis — v1.6
// nyra test tests/nyra/struct_serde_nested_test.ny

import "stdlib/testing.ny"
import "stdlib/json/mod.ny"

struct Inner {
    x: i32
    ok: bool
}

struct Outer {
    name: string
    inner: Inner
}

test fn test_nested_struct_json_roundtrip() {
    let o = Outer { name: "wrap", inner: Inner { x: 7, ok: true } }
    let json = Outer_json_encode(o)
    let o2 = Outer_json_decode(json)
    assert_str_eq(o2.name, "wrap")
    assert_eq(o2.inner.x, 7)
    assert_bool(o2.inner.ok)
}
