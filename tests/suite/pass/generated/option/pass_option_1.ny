enum Opt1 {
    None
    Some(i32)
}
fn main() {
    let o = Opt1.Some(1)
    let v = match o {
        Opt1.None => 0
        Opt1.Some(x) => x
    }
    print(v)
}
