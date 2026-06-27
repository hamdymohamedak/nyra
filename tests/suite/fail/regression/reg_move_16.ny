fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r16"
    take(s)
    print(s) //~ ERROR was moved
}
