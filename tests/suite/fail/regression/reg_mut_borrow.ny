fn main() {
    let mut v = 0
    let r = &v
    v = 1 //~ ERROR because it is borrowed
    print(r)
}
