fn take(x: string) -> void { print(x) }
fn main() {
    let msg = "hello"
    take(msg)
    print(msg) //~ ERROR was moved
}
