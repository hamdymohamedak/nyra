use std::hint::black_box;

fn main() {
    let n: i32 = 4_000_000;
    let mut h: i32 = 0;
    let mut i: i32 = 0;
    while i < n {
        h = (h + i * 31 + 17) % 999983;
        i += 1;
    }
    black_box(h);
}
