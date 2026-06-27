enum Opt100 {
    None
    Some(i32)
}
fn main() {
    let o = Opt100.Some(100)
    let v = match o {
        Opt100.None => 0
        Opt100.Some(x) => x
    }
    print(v)
}
