struct Box {
    id: i32
    label: string
}
fn main() {
    let b = Box { id: 10 label: "item" }
    print(b.id)
    print(b.label)
}
