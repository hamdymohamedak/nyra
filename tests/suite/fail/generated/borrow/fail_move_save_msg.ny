fn save(x: string) -> void { print(x) }
fn main() {
    let msg = "hello"
    save(msg)
    print(msg) //~ ERROR was moved
}
