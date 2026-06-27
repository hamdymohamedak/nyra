fn main() {
    mut acc = 0
    let n = 270000000
    let mod = 1000000007
    mut i = 0
    while i < n {
        let t = (i % 997) * 31
        acc = (acc + t + (acc % 4099)) % mod
        i = i + 1
    }
    print(acc)
}
