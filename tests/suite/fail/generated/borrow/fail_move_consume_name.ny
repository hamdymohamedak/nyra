fn consume(x: string) -> void { print(x) }
fn main() {
    let name = "hello"
    consume(name)
    print(name) //~ ERROR was moved
}
