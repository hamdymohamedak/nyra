enum Tag5 {
    A
    B
    C
}
fn main() {
    let t = Tag5.B
    let n = match t {
        Tag5.A => 1
        Tag5.B => 5
        Tag5.C => 3
    }
    print(n)
}
