extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let mut bump = 0
    let mut i = 0
    while i < 500000 {
        bump = (bump + 16) % 67108864
        acc = (acc + bump + i) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
