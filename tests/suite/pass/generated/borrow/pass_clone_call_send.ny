fn send(x: string) -> void { print(x) }
fn main() {
    let s = "ok"
    send(clone s)
    print(s)
}
