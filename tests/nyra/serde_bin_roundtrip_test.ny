// NBF struct binary roundtrip — zero-types
// nyra test tests/nyra/serde_bin_roundtrip_test.ny

import "stdlib/testing.ny"

struct User {
    name: string
    age: i32
}

test fn test_user_bin_roundtrip() {
    let u = User { name: "Ada", age: 30 }
    let blob = User_bin_encode(u)
    let u2 = User_bin_decode(blob)
    assert_str_eq(u2.name, "Ada")
    assert_eq(u2.age, 30)
}
