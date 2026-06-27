use std::hint::black_box;

fn main() {
    let n: i64 = 375_000_000;
    let m: i64 = 1_000_000_007;
    let mut sum: i64 = 0;
    let mut i: i64 = 0;
    while i < n {
        sum = (sum + i).rem_euclid(m);
        i += 1;
    }
    println!("{}", black_box(sum));
}
