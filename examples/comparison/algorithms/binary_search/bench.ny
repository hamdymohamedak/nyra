extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let n = 50000
    let mut lo = 0
    let mut hi = n
    let target = n / 3
    let mut probes = 0
    while lo < hi && probes < 32 {
        let mid = (lo + hi) / 2
        if mid < target {
            lo = mid + 1
        } else {
            hi = mid
        }
        acc = (acc + mid) % 1000000007
        probes = probes + 1
    }

    print(blackbox_i32(acc))
}
