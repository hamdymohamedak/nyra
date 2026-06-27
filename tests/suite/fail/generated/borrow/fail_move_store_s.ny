fn store(x: string) -> void { print(x) }
fn main() {
    let s = "hello"
    store(s)
    print(s) //~ ERROR was moved
}
