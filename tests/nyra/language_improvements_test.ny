import "stdlib/encoding/base64.ny"

struct Color repr(C) {
    r: u8
    g: u8
    b: u8
    a: u8
}

fn rgba(r: i32, g: i32, b: i32, a: i32) -> Color {
    return Color { r: r, g: g, b: b, a: a }
}

fn make_strokes() -> [i32; 4] {
    return [10, 20, 30, 40]
}

fn shift_and_mask(x: i32) -> i32 {
    return (x << 2) | 1
}

fn hex_pack(x: i32) -> i32 {
    return (x << 8) | 0xff
}

fn bump(mut n: i32) -> i32 {
    n = n + 1
    return n
}

struct Slots {
    data: [i32; 4]
}

fn init_slots() -> Slots {
    return Slots { data: [0; 4] }
}

fn touch_slots(mut s: Slots) -> i32 {
    s.data[2] = 99
    return s.data[2]
}

fn dyn_str_eq() -> i32 {
    let a = strcat("hel", "lo")
    if a == "hello" {
        return 1
    }
    return 0
}

fn dyn_str_eq_calls() -> i32 {
    let a = base64_encode("Hi")
    let b = base64_encode("Hi")
    if a == b {
        return 1
    }
    return 0
}

fn str_order() -> i32 {
    if "a" < "b" && "z" >= "y" {
        return 1
    }
    return 0
}

const STROKE_MAX = 4

fn test_const_repeat() -> [i32; 4] {
    return [-1; STROKE_MAX]
}

struct Counter {
    n: i32
}

fn bump_counter(mut c: Counter) -> void {
    c.n = c.n + 1
}

fn test_mut_struct_inout() -> i32 {
    let mut c = Counter { n: 5 }
    bump_counter(c)
    return c.n
}

fn test_u8_call() -> Color {
    return rgba(40, 80, 120, 255)
}

fn test_repeat() -> [i32; 4] {
    return [0; 4]
}

test fn test_language_improvements() {
    let c = test_u8_call()
    let arr = make_strokes()
    let z = test_repeat()
    let bits = shift_and_mask(3)
    let casted: u8 = 200 as u8
    assert_eq(c.r, 40)
    assert_eq(arr[0], 10)
    assert_eq(z[3], 0)
    assert_eq(bits, 13)
    assert_eq(casted as i32, 200)
    let via_call = rgba(1, 2, 3, 4)
    assert_eq(via_call.a, 4)
    assert_eq(hex_pack(1), 511)
    assert_eq(bump(9), 10)
    assert_eq(dyn_str_eq(), 1)
    assert_eq(dyn_str_eq_calls(), 1)
    assert_eq(str_order(), 1)
    assert_eq(test_const_repeat()[0], -1)
    assert_eq(test_mut_struct_inout(), 6)
    assert_eq(touch_slots(init_slots()), 99)
    let enc = base64_encode("Hi")
    assert_str_eq(enc, "SGk=")
    let dec = base64_decode("SGk=")
    assert_eq(strlen(dec), 2)
    assert_eq(char_at(dec, 0), 72)
    assert_eq(char_at(dec, 1), 105)
}
