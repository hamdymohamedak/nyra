fn main() {
    let n: i64 = 200;
    let mut sum: i64 = 0;
    for i in 0..n {
        for j in 0..n {
            sum += i * j;
        }
    }
    println!("{}", sum);
}
