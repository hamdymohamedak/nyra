allow_extended
extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut acc: i32 = 0
    let mut i: i32 = 0
    while i < 5000 {
        spawn {
            blackbox_i32(i)
        }
        i = i + 1
    }
    acc = 5000 % 1000000007

    print(blackbox_i32(acc))
}
