extern fn blackbox_i32(x: i32) -> i32

fn main() {
    mut acc = 0
    let n = 180000000
    mut i = 0
    while i < n {
        let term = (i % 997) * 31
        acc = (acc + term) % 997
        i = i + 1
    }
    print(blackbox_i32(acc))
}
