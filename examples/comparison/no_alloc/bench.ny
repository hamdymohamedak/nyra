extern fn blackbox_i32(x: i32) -> i32

fn main() {
    mut x = 1
    mut y = 2
    mut acc = 0
    let n = 5000000
    for i in 0..n {
        acc = acc + x + y
        x = x + 1
        y = y + 1
    }
    blackbox_i32(acc)
}
