fn main() {
    let n = 40
    mut a = 0
    mut b = 1
    mut i = 0
    while i < n {
        let t = a + b
        a = b
        b = t
        i = i + 1
    }
    print(b)
}
