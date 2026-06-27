// Serialize trait demo — zero-types
// nyra run examples/serde_traits.ny

struct User {
    name: string
    age: i32
}

fn main() {
    let u = User { name: "Ada", age: 30 }
    let json = u.to_json()
    print(json)
    let u2 = User_json_decode(json)
    print(u2.name)
    print(u2.age)
}
