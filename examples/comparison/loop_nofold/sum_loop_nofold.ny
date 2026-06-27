extern fn blackbox_i32(x: i32) -> i32

fn main() {
    mut sum = 0
    mut i = 0
    let n = 375000000
    let mod = 1000000007
    while i < n {
        sum = (sum + i) % mod
        i = i + 1
    }
    print(blackbox_i32(sum))
}
