fn save(x: string) -> void { print(x) }
fn main() {
    let s = "hello"
    save(s)
    print(s) //~ ERROR was moved
}
