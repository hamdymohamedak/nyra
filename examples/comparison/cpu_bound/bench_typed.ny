extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut acc = 0
    let n: i32 = 180000000
    let mut i = 0
    while i < n {
        let term = (i % 997) * 31
        acc = (acc + term) % 997
        i = i + 1
    }
    print(blackbox_i32(acc))
}
