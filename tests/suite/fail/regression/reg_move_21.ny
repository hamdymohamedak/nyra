fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r21"
    take(s)
    print(s) //~ ERROR was moved
}
