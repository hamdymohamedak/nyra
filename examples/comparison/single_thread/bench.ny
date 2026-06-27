fn main() {
    mut sum = 0
    let n = 200
    for i in 0..n {
        for j in 0..n {
            sum = sum + i * j
        }
    }
    print(sum)
}
