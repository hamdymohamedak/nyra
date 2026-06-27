enum Opt50 {
    None
    Some(i32)
}
fn main() {
    let o = Opt50.Some(50)
    let v = match o {
        Opt50.None => 0
        Opt50.Some(x) => x
    }
    print(v)
}
