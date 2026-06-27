extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc: i32 = 0
    let n: i32 = 5000000
    for i in 0..n {
        acc = (acc + i) % 999983
    }
    blackbox_i32(acc)
}
