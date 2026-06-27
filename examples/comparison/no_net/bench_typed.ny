extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut h: i32 = 0
    let n: i32 = 4000000
    for i in 0..n {
        h = (h + i * 31 + 17) % 999983
    }
    blackbox_i32(h)
}
