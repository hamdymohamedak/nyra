fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r13"
    take(s)
    print(s) //~ ERROR was moved
}
