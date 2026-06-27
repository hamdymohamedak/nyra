struct Box {
    id: i32
    label: string
}
fn main() {
    let b = Box { id: 1 label: "item" }
    print(b.id)
    print(b.label)
}
