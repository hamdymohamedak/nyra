// Struct JSON encode/decode synthesis (v1.5)
// nyra run examples/struct_serde.ny

import "stdlib/json/mod.ny"

struct User {
    name: string
    age: i32
}

fn main() {
    let u = User { name: "Ada", age: 30 }
    let json = User_json_encode(u)
    let u2 = User_json_decode(json)
    print(u2.name)
    print(u2.age)
}
