struct Color_u8 {
    r: u8
    g: u8
    b: u8
    a: u8
}

test fn test_break_while() {
    let mut i = 0
    while i < 10 {
        i = i + 1
        if i == 3 {
            break
        }
    }
    assert_eq(i, 3)
}

test fn test_clone_method() {
    let a = "hello"
    let b = a.clone()
    assert_eq(b.length(), 5)
}

test fn test_clone_prefix() {
    let a = "world"
    let b = clone a
    assert_eq(b.length(), 5)
}

test fn test_u8_struct_field() {
    let c = Color_u8 { r: 18, g: 52, b: 86, a: 255 }
    assert_eq(c.r, 18)
    assert_eq(c.a, 255)
}
