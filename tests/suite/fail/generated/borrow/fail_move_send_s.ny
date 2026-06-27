fn send(x: string) -> void { print(x) }
fn main() {
    let s = "hello"
    send(s)
    print(s) //~ ERROR was moved
}
