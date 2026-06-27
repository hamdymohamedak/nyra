fn send(x: string) -> void { print(x) }
fn main() {
    let name = "hello"
    send(name)
    print(name) //~ ERROR was moved
}
