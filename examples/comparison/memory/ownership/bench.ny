struct Pair {
    a: i32
    b: i32
}

fn use_pair(p) {
    return p.a + p.b
}

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let mut i = 0
    while i < 500000 {
        let p = Pair { a: i % 1000, b: (i * 7) % 1000 }
        acc = (acc + use_pair(p)) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
