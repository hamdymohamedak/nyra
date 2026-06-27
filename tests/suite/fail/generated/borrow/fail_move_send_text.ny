fn send(x: string) -> void { print(x) }
fn main() {
    let text = "hello"
    send(text)
    print(text) //~ ERROR was moved
}
