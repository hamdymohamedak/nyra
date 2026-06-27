// Optional color helpers — works with any struct that has u8 r,g,b,a fields via rgba values.

struct Rgba {
    r: u8
    g: u8
    b: u8
    a: u8
}

fn rgba(r: i32, g: i32, b: i32, a: i32) -> Rgba {
    return Rgba { r: r, g: g, b: b, a: a }
}

fn rgba_u8(r: u8, g: u8, b: u8, a: u8) -> Rgba {
    return Rgba { r: r, g: g, b: b, a: a }
}
