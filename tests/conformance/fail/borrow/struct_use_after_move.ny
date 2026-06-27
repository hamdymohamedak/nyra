struct Item {
    id: i32
    name: string
}

fn store(x: Item) -> void {
    print(x.id)
}

fn main() {
    let item = Item { id: 3 name: "x" }
    store(item)
    print(item.name)
}
