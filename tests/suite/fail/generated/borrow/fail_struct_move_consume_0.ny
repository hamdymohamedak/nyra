struct Item {
    id: i32
    name: string
}
fn consume(x: Item) -> void { print(x.id) }
fn main() {
    let item = Item { id: 1 name: "x" }
    consume(item)
    print(item.name) //~ ERROR was moved
}
