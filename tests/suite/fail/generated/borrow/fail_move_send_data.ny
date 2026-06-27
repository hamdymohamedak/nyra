fn send(x: string) -> void { print(x) }
fn main() {
    let data = "hello"
    send(data)
    print(data) //~ ERROR was moved
}
