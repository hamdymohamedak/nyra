fn take(x: string) -> void { print(x) }
fn main() {
    let data = "hello"
    take(data)
    print(data) //~ ERROR was moved
}
