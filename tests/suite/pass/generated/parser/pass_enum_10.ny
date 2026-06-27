enum Tag10 {
    A
    B
    C
}
fn main() {
    let t = Tag10.B
    let n = match t {
        Tag10.A => 1
        Tag10.B => 10
        Tag10.C => 3
    }
    print(n)
}
