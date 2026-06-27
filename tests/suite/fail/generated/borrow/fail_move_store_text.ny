fn store(x: string) -> void { print(x) }
fn main() {
    let text = "hello"
    store(text)
    print(text) //~ ERROR was moved
}
