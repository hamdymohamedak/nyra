enum Opt10 {
    None
    Some(i32)
}
fn main() {
    let o = Opt10.Some(10)
    let v = match o {
        Opt10.None => 0
        Opt10.Some(x) => x
    }
    print(v)
}
