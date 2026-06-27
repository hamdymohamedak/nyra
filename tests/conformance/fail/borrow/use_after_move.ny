fn consume(s: string) -> void {
    print(s)
}

fn main() {
    let msg = "moved"
    consume(msg)
    print(msg)
}
