// Serialize / Deserialize trait demo — typed
// nyra run examples/serde_traits.typed.ny

struct User {
    name: string
    age: i32
}

fn main() {
    let u = User { name: "Ada", age: 30 }
    let json: string = u.to_json()
    print(json)
    let u2: User = Deserialize_User_from_json(json)
    print(u2.name)
    print(u2.age)
    let blob: ptr = u.to_bytes()
    let u3: User = User_bin_decode(blob)
    print(u3.name)
}
