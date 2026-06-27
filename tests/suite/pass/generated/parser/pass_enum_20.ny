enum Tag20 {
    A
    B
    C
}
fn main() {
    let t = Tag20.B
    let n = match t {
        Tag20.A => 1
        Tag20.B => 20
        Tag20.C => 3
    }
    print(n)
}
