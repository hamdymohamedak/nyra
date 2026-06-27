fn take(x: string) -> void { print(x) }
fn main() {
    let name = "hello"
    take(name)
    print(name) //~ ERROR was moved
}
