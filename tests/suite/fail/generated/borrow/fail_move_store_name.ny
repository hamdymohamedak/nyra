fn store(x: string) -> void { print(x) }
fn main() {
    let name = "hello"
    store(name)
    print(name) //~ ERROR was moved
}
