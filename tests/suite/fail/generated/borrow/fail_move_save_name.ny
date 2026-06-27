fn save(x: string) -> void { print(x) }
fn main() {
    let name = "hello"
    save(name)
    print(name) //~ ERROR was moved
}
