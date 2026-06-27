// Contrast: User returned from fn → GlobalEscape; string field cloned on return path.
struct User {
    id: i32
    name: string
}

fn mk() -> User {
    return User { id: 1, name: "Hamdy" }
}

fn main() {
    mut acc = 0
    mut i = 0
    while i < 100000 {
        let user = mk()
        acc = acc + user.id
        i = i + 1
    }
    print(acc)
}
