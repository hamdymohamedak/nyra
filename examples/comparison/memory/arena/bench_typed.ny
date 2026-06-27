extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut acc: i32 = 0
    let mut bump: i32 = 0
    let mut i: i32 = 0
    while i < 500000 {
        bump = (bump + 16) % 67108864
        acc = (acc + bump + i) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
