fn take(x: string) -> void { print(x) }
fn main() {
    let text = "hello"
    take(text)
    print(text) //~ ERROR was moved
}
