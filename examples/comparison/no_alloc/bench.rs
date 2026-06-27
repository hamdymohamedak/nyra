use std::hint::black_box;

fn main() {
    let n: i32 = 5_000_000;
    let mut x: i32 = 1;
    let mut y: i32 = 2;
    let mut acc: i32 = 0;
    let mut i: i32 = 0;
    while i < n {
        acc = acc.wrapping_add(x).wrapping_add(y);
        x += 1;
        y += 1;
        i += 1;
    }
    black_box(acc);
}
