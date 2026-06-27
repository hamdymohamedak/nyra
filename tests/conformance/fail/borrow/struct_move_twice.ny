struct Box {
    value: i32
    label: string
}

fn take(b: Box) -> void {
    print(b.value)
}

fn main() {
    let b = Box { value: 9 label: "x" }
    take(b)
    print(b.value)
}
