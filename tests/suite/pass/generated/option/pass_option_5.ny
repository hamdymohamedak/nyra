enum Opt5 {
    None
    Some(i32)
}
fn main() {
    let o = Opt5.Some(5)
    let v = match o {
        Opt5.None => 0
        Opt5.Some(x) => x
    }
    print(v)
}
