// Official Serialize trait — zero-types
// nyra test tests/nyra/serde_traits_test.ny

import "stdlib/testing.ny"

extern fn bin_blob_payload_len(blob: ptr) -> i32

struct User {
    name: string
    age: i32
}

test fn test_serialize_to_json_trait() {
    let u = User { name: "Ada", age: 30 }
    let json = u.to_json()
    let u2 = User_json_decode(json)
    assert_str_eq(u2.name, "Ada")
    assert_eq(u2.age, 30)
}

test fn test_json_decode_roundtrip() {
    let u = User { name: "Grace", age: 36 }
    let json = u.to_json()
    let u2 = User_json_decode(json)
    assert_str_eq(u2.name, "Grace")
    assert_eq(u2.age, 36)
}

test fn test_serialize_to_bytes_wraps_json() {
    let u = User { name: "Lin", age: 28 }
    let blob = u.to_bytes()
    let len = bin_blob_payload_len(blob)
    if len < 10 {
        assert_eq(0, 1)
    }
}

test fn test_deserialize_from_json_trait() {
    let u = User { name: "Katherine", age: 42 }
    let json = u.to_json()
    let u2 = Deserialize_User_from_json(json)
    assert_str_eq(u2.name, "Katherine")
    assert_eq(u2.age, 42)
}

test fn test_serialize_to_bytes_native_bin() {
    let u = User { name: "Lin", age: 28 }
    let blob = u.to_bytes()
    let u2 = User_bin_decode(blob)
    assert_str_eq(u2.name, "Lin")
    assert_eq(u2.age, 28)
}
