extern fn malloc(size: i64) -> ptr
extern fn free(p: ptr) -> void

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let mut i = 0
    while i < 500000 {
        let p = malloc(16)
        acc = (acc + i) % 1000000007
        free(p)
        i = i + 1
    }

    print(blackbox_i32(acc))
}
