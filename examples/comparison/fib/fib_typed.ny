fn main() -> void {
    let steps: i32 = 375000000
    let mod: i32 = 1000000007
    let mut a = 0
    let mut b = 1
    let mut i = 0
    while i < steps {
        let t = (a + b) % mod
        a = b
        b = t
        i = i + 1
    }
    print(b)
}
