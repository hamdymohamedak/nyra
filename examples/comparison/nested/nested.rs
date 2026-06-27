fn main() {
    let n: i32 = 4000;
    let m: i64 = 1_000_000_007;
    let mut sum: i64 = 0;
    for i in 0..n {
        for j in 0..n {
            sum = (sum + (i as i64) * (j as i64)).rem_euclid(m);
        }
    }
    println!("{}", sum);
}
