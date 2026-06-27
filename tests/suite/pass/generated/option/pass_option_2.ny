enum Opt2 {
    None
    Some(i32)
}
fn main() {
    let o = Opt2.Some(2)
    let v = match o {
        Opt2.None => 0
        Opt2.Some(x) => x
    }
    print(v)
}
