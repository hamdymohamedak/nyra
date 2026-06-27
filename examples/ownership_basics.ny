// Ownership UX: auto-borrow at calls, Clone when you need a copy.
// See docs/rfcs/0006-ownership-ux-and-inference.md

struct User {
    name: string
    age: i32
}

fn create_user(name: string) -> User {
    return User { name: name, age: 25 }
}

fn save(user: &User) -> void {
    print(user.age)
}

fn main() {
    let user = create_user("Ahmed")
    save(user)
    print(user.name)

    let s = "hello"
    let copy = clone s
    print(s)
    print(copy)
}
