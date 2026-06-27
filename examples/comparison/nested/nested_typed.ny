fn main() -> void {
    let mut sum = 0
    let n: i32 = 4000
    let mod: i32 = 1000000007
    for i in 0..n {
        for j in 0..n {
            sum = (sum + i * j) % mod
        }
    }
    print(sum)
}
