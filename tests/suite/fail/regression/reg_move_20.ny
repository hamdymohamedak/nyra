fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r20"
    take(s)
    print(s) //~ ERROR was moved
}
