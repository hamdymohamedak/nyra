extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut acc: i32 = 0
    let mut i: i32 = 0
    let n: i32 = 50000
    while i < n {
        let t = n - i
        acc = (acc + t % 997) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
