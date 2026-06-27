// Scalar primitives — zero-types style (inference only where annotated types omitted)

fn main() -> void {
    // Signed integers (literal default is i32)
    let small: i32 = 127
    let negative: i32 = -128
    let wide: i64 = 9223372036854775807

    // Unsigned — annotate when you need a specific width
    let byte: i32 = 255
    let rgb_g: i32 = 200

    // Float, bool, char
    let pi: f64 = 3.14159
    let precise: f32 = 0.5f32
    let ok = true
    let letter = 'a'
    let arabic = 'ب'

    print(small + negative)
    print(byte)
    print(pi)
    print(precise)
    print(ok)
    print(letter)
    print(arabic)
}
