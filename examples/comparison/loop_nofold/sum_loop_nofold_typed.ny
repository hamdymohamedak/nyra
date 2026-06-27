extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut sum = 0
    let mut i = 0
    let n: i32 = 375000000
    let mod: i32 = 1000000007
    while i < n {
        sum = (sum + i) % mod
        i = i + 1
    }
    print(blackbox_i32(sum))
}
