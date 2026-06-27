extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut x: i32 = 1
    let mut y: i32 = 2
    let mut acc: i32 = 0
    let n: i32 = 5000000
    for i in 0..n {
        acc = acc + x + y
        x = x + 1
        y = y + 1
    }
    blackbox_i32(acc)
}
