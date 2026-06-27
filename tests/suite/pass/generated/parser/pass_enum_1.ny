enum Tag1 {
    A
    B
    C
}
fn main() {
    let t = Tag1.B
    let n = match t {
        Tag1.A => 1
        Tag1.B => 1
        Tag1.C => 3
    }
    print(n)
}
