fn consume(x: string) -> void { print(x) }
fn main() {
    let s = "hello"
    consume(s)
    print(s) //~ ERROR was moved
}
