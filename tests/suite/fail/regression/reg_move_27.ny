fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r27"
    take(s)
    print(s) //~ ERROR was moved
}
