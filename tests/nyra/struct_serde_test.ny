// Struct JSON encode/decode synthesis — v1.5
// nyra test tests/nyra/struct_serde_test.ny

import "stdlib/testing.ny"
import "stdlib/json/mod.ny"

struct User {
    name: string
    age: i32
}

struct Flags {
    active: bool
    label: string
}

test fn test_user_json_roundtrip() {
    let u = User { name: "nyra", age: 21 }
    let json = User_json_encode(u)
    let u2 = User_json_decode(json)
    assert_str_eq(u2.name, "nyra")
    assert_eq(u2.age, 21)
}

test fn test_user_to_json_trait() {
    let u = User { name: "nyra", age: 21 }
    let json = u.to_json()
    assert_str_eq(json, User_json_encode(u))
}

test fn test_flags_json_roundtrip() {
    let f = Flags { active: true, label: "ok" }
    let json = Flags_json_encode(f)
    let f2 = Flags_json_decode(json)
    assert_bool(f2.active)
    assert_str_eq(f2.label, "ok")
}
