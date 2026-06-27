fn consume(x: string) -> void { print(x) }
fn main() {
    let msg = "hello"
    consume(msg)
    print(msg) //~ ERROR was moved
}
