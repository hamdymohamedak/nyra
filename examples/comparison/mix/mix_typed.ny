fn main() -> void {
    let mut acc = 0
    let n: i32 = 270000000
    let mod: i32 = 1000000007
    let mut i = 0
    while i < n {
        let t = (i % 997) * 31
        acc = (acc + t + (acc % 4099)) % mod
        i = i + 1
    }
    print(acc)
}
