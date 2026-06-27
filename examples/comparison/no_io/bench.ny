extern fn blackbox_i32(x: i32) -> i32

fn main() {
    mut acc = 0
    let n = 5000000
    for i in 0..n {
        acc = (acc + i) % 999983
    }
    blackbox_i32(acc)
}
