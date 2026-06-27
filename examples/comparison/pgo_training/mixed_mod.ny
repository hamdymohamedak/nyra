// PGO training: chained positive mod + add (feeds cpu_bound-style hot paths).
extern fn blackbox_i32(x: i32) -> i32

fn main() {
    mut acc = 0
    let n = 12000000
    mut i = 0
    while i < n {
        let t = (i % 997) * 31
        acc = (acc + t) % 997
        acc = (acc + (i % 4099)) % 1000000007
        i = i + 1
    }
    print(blackbox_i32(acc))
}
