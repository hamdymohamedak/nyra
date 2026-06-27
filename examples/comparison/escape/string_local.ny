// Escape analysis: struct literal + string literal stay NoEscape → no clone in @main.
struct User {
    id: i32
    name: string
}

fn main() {
    let user = User { id: 1, name: "Hamdy" }
    mut acc = 0
    mut i = 0
    while i < 80000000 {
        acc = acc + user.id
        i = i + 1
    }
    print(acc)
}
