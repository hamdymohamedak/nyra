// Official Serialize trait — typed
// nyra test tests/nyra/serde_traits_test.typed.ny

import "stdlib/testing.ny"

extern fn bin_blob_payload_len(blob: ptr) -> i32

struct User {
    name: string
    age: i32
}

test fn test_serialize_to_json_trait() {
    let u = User { name: "Ada", age: 30 }
    let json: string = u.to_json()
    let u2: User = User_json_decode(json)
    assert_str_eq(u2.name, "Ada")
    assert_eq(u2.age, 30)
}

test fn test_json_decode_roundtrip() {
    let u = User { name: "Grace", age: 36 }
    let json: string = u.to_json()
    let u2: User = User_json_decode(json)
    assert_str_eq(u2.name, "Grace")
    assert_eq(u2.age, 36)
}

test fn test_serialize_to_bytes_wraps_json() {
    let u = User { name: "Lin", age: 28 }
    let blob: ptr = u.to_bytes()
    let len: i32 = bin_blob_payload_len(blob)
    if len < 10 {
        assert_eq(0, 1)
    }
}
