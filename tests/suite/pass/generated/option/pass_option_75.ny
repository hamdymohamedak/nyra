enum Opt75 {
    None
    Some(i32)
}
fn main() {
    let o = Opt75.Some(75)
    let v = match o {
        Opt75.None => 0
        Opt75.Some(x) => x
    }
    print(v)
}
