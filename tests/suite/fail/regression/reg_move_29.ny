fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r29"
    take(s)
    print(s) //~ ERROR was moved
}
