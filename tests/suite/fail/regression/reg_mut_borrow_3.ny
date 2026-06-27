fn main() {
    let mut n = 3
    let r = &mut n
    n = n + 1 //~ ERROR because it is borrowed
    print(r)
}
