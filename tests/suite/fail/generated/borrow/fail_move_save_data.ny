fn save(x: string) -> void { print(x) }
fn main() {
    let data = "hello"
    save(data)
    print(data) //~ ERROR was moved
}
