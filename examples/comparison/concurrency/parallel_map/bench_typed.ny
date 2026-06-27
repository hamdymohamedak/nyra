allow_extended
extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut acc: i32 = 0
    parallel for i in 0..200000 {
        blackbox_i32((i % 997) * 31)
    }
    let mut i: i32 = 0
    while i < 200000 {
        acc = (acc + (i % 997) * 31) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
