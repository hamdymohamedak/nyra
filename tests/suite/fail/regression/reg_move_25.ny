fn take(x: string) -> void { print(x) }
fn main() {
    let s = "r25"
    take(s)
    print(s) //~ ERROR was moved
}
