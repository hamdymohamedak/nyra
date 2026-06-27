fn send(x: string) -> void { print(x) }
fn main() {
    let msg = "hello"
    send(msg)
    print(msg) //~ ERROR was moved
}
