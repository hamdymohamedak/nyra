fn save(x: string) -> void { print(x) }
fn main() {
    let text = "hello"
    save(text)
    print(text) //~ ERROR was moved
}
