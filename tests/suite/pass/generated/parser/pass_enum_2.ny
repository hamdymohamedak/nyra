enum Tag2 {
    A
    B
    C
}
fn main() {
    let t = Tag2.B
    let n = match t {
        Tag2.A => 1
        Tag2.B => 2
        Tag2.C => 3
    }
    print(n)
}
