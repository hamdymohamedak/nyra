// Struct JSON with Vec<i32> field — v1.7
// nyra test tests/nyra/struct_serde_vec_test.ny

import "stdlib/testing.ny"
import "stdlib/json/mod.ny"
import "stdlib/vec.ny"

struct Scores {
    name: string
    values: ptr
}

test fn test_vec_i32_json_roundtrip() {
    let v = Vec_i32_new()
    Vec_i32_push(v, 1)
    Vec_i32_push(v, 2)
    Vec_i32_push(v, 3)
    let s = Scores { name: "game", values: v }
    let json = Scores_json_encode(s)
    let s2 = Scores_json_decode(json)
    assert_str_eq(s2.name, "game")
    assert_eq(Vec_i32_len(s2.values), 3)
    assert_eq(Vec_i32_get(s2.values, 0), 1)
    assert_eq(Vec_i32_get(s2.values, 2), 3)
}
