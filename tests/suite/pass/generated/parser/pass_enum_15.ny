enum Tag15 {
    A
    B
    C
}
fn main() {
    let t = Tag15.B
    let n = match t {
        Tag15.A => 1
        Tag15.B => 15
        Tag15.C => 3
    }
    print(n)
}
