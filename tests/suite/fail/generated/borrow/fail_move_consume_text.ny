fn consume(x: string) -> void { print(x) }
fn main() {
    let text = "hello"
    consume(text)
    print(text) //~ ERROR was moved
}
