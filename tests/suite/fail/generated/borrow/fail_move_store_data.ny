fn store(x: string) -> void { print(x) }
fn main() {
    let data = "hello"
    store(data)
    print(data) //~ ERROR was moved
}
