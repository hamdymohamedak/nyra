fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r4"
    take(s)
    print(s) //~ ERROR was moved
}
