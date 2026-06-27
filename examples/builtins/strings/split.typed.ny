fn main() -> void {
    let parts: VecStr = "a,b,c".split(",")
    print(parts.length())
    for p in parts {
        print(p)
    }
}
