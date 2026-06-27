// Nested struct JSON — v1.6 (zero-types)
// nyra run examples/struct_serde_nested.ny

import "stdlib/json/mod.ny"

struct Inner {
    x: i32
    ok: bool
}

struct Outer {
    name: string
    inner: Inner
}

fn main() {
    let o = Outer { name: "demo", inner: Inner { x: 10, ok: true } }
    let json = Outer_json_encode(o)
    let o2 = Outer_json_decode(json)
    print(o2.inner.x)
}
