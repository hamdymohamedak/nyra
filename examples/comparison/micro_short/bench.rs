fn main() {
    let n: i64 = 125_000;
    let mut sum: i64 = 0;
    let mut i: i64 = 0;
    while i < n {
        sum += i;
        i += 1;
    }
    println!("{}", sum);
}
