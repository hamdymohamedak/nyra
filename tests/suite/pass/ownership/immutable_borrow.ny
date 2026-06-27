struct User {
    name: string
    age: i32
}
fn peek(u: &User) -> void {
    print(u.age)
}
fn main() {
    let user = User { name: "Ada" age: 30 }
    peek(user)
    print(user.name)
}
