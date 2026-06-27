fn main() {
    let n: i32 = 40
    let mut a: i32 = 0
    let mut b: i32 = 1
    let mut i: i32 = 0
    while i < n {
        let t: i32 = a + b
        a = b
        b = t
        i = i + 1
    }
    print(b)
}
