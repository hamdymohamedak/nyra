enum Opt25 {
    None
    Some(i32)
}
fn main() {
    let o = Opt25.Some(25)
    let v = match o {
        Opt25.None => 0
        Opt25.Some(x) => x
    }
    print(v)
}
