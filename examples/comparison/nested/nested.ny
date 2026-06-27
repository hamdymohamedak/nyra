fn main() {
    mut sum = 0
    let n = 4000
    let mod = 1000000007
    for i in 0..n {
        for j in 0..n {
            sum = (sum + i * j) % mod
        }
    }
    print(sum)
}
