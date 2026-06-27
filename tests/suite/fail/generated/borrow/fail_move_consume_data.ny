fn consume(x: string) -> void { print(x) }
fn main() {
    let data = "hello"
    consume(data)
    print(data) //~ ERROR was moved
}
