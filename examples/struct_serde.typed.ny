// Struct JSON encode/decode — explicit types
// nyra run examples/struct_serde.typed.ny

import "stdlib/json/mod.ny"

struct User {
    name: string
    age: i32
}

fn main() -> void {
    let u: User = User { name: "Ada", age: 30 }
    let json: string = User_json_encode(u)
    let u2: User = User_json_decode(json)
    print(u2.name)
    print(u2.age)
}
