extern fn malloc(size: i64) -> ptr
extern fn free(p: ptr) -> void

struct Point {
    x: i32
    y: i32
}

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let mut i = 0
    while i < 500000 {
        let p = malloc(8)
        let node = Point { x: i % 997, y: (i * 3) % 991 }
        acc = (acc + node.x + node.y) % 1000000007
        free(p)
        i = i + 1
    }

    print(blackbox_i32(acc))
}
