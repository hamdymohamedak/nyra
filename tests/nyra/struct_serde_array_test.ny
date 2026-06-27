// Struct JSON with fixed [i32; N] field — v1.7
// nyra test tests/nyra/struct_serde_array_test.ny

import "stdlib/testing.ny"
import "stdlib/json/mod.ny"

struct Triple {
    tag: string
    data: [i32; 3]
}

test fn test_fixed_array_json_roundtrip() {
    let t = Triple { tag: "nums", data: [4, 5, 6] }
    let json = Triple_json_encode(t)
    let t2 = Triple_json_decode(json)
    assert_str_eq(t2.tag, "nums")
    assert_eq(t2.data[0], 4)
    assert_eq(t2.data[2], 6)
}
