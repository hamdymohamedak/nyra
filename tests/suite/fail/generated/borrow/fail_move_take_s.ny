fn take(x: string) -> void { print(x) }
fn main() {
    let s = "hello"
    take(s)
    print(s) //~ ERROR was moved
}
