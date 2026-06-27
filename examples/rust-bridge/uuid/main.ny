import "rust/uuid"

fn main() {
    let id = new_v4()
    print(id)
    let parsed = parse(id)
    print(parsed)
}
