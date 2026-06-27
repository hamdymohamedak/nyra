fn main() {
    let mut v = 1
    let r = &v
    v = 2 //~ ERROR because it is borrowed
    print(r)
}
