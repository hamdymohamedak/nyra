fn main() {
    let mut sum: i32 = 0
    let n: i32 = 200
    for i in 0..n {
        for j in 0..n {
            sum = sum + i * j
        }
    }
    print(sum)
}
