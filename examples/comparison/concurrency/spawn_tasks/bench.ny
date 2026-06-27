allow_extended
extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let mut i = 0
    while i < 5000 {
        spawn {
            blackbox_i32(i)
        }
        i = i + 1
    }
    acc = 5000 % 1000000007

    print(blackbox_i32(acc))
}
