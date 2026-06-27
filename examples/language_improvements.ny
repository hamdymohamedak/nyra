// Language improvements demo: u8 coercion, bitwise ops, array repeat, array return.
struct Color {
    r: u8
    g: u8
    b: u8
    a: u8
}

fn rgba(r: i32, g: i32, b: i32, a: i32) -> Color {
    return Color { r: r, g: g, b: b, a: a }
}

fn make_ids() -> [i32; 4] {
    return [1, 2, 3, 4]
}

fn pack(x: i32) -> i32 {
    return (x << 8) | 0xff
}

fn bump(mut n: i32) -> i32 {
    n = n + 1
    return n
}

fn main() -> i32 {
    let c = rgba(10, 20, 30, 255)
    let ids = make_ids()
    let zeros = [0; 4]
    let p = pack(1)
    let narrow: u8 = 200 as u8
    if c.r != 10 { return 11 }
    if ids[0] != 1 { return 12 }
    if zeros[2] != 0 { return 13 }
    if p != 511 { return 14 }
    if narrow as i32 != 200 { return 15 }
    if bump(4) != 5 { return 16 }
    return 0
}
