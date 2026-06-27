fn main() {
    mut sum = 0
    let n = 375000000
    let mod = 1000000007
    mut i = 0
    while i < n {
        sum = (sum + i) % mod
        i = i + 1
    }
    print(sum)
}
