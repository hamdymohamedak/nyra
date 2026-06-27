fn main() {
    let mut v = 10
    let r = &v
    v = v + 1 //~ ERROR because it is borrowed
    print(r)
}
