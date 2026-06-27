fn consume(x: string) -> void { print(x) }
fn main() {
    let s = "ok"
    consume(clone s)
    print(s)
}
