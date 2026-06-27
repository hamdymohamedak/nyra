fn store(x: string) -> void { print(x) }
fn main() {
    let msg = "hello"
    store(msg)
    print(msg) //~ ERROR was moved
}
