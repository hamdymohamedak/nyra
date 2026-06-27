use std::hint::black_box;

fn main() {
    let n: i64 = 180_000_000;
    let mut acc: i64 = 0;
    for i in 0..n {
        acc = (acc + (i % 997) * 31).rem_euclid(997);
    }
    println!("{}", black_box(acc));
}
