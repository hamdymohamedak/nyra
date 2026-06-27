use std::hint::black_box;

fn main() {
    let n: i32 = 5_000_000;
    let mut acc: i32 = 0;
    let mut i: i32 = 0;
    while i < n {
        acc = (acc + i) % 999983;
        i += 1;
    }
    black_box(acc);
}
