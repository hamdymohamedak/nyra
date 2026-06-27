struct Item {
    id: i32
    name: string
}
fn save(x: Item) -> void { print(x.id) }
fn main() {
    let item = Item { id: 2 name: "x" }
    save(item)
    print(item.name) //~ ERROR was moved
}
