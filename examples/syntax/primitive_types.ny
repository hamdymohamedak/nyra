// Scalar primitives — zero-types style (inference only where annotated types omitted)

fn main() {
    // Signed integers (literal default is i32)
    let small = 127
    let negative = -128
    let wide = 9223372036854775807

    // Unsigned — annotate when you need a specific width
    let byte = 255
    let rgb_g = 200

    // Float, bool, char
    let pi = 3.14159
    let precise = 0.5f32
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
