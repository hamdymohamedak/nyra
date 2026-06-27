fn main() {
    let steps = 375000000
    let mod = 1000000007
    mut a = 0
    mut b = 1
    mut i = 0
    while i < steps {
        let t = (a + b) % mod
        a = b
        b = t
        i = i + 1
    }
    print(b)
}
