enum Code { Zero, One, Other }

struct Point {
    x: i32
    y: i32
}

test fn test_if_else() {
    let mut n = 0
    if 1 == 1 {
        n = 10
    } else {
        n = 99
    }
    assert_eq(n, 10)
}

test fn test_array_literal() {
    let xs = [1, 2, 3]
    assert_eq(xs.len(), 3)
    assert_eq(xs[1], 2)
}

test fn test_match_enum() {
    let code = Code.One
    let n = match code {
        Code.Zero => 0
        Code.One => 1
        Code.Other => 99
    }
    assert_eq(n, 1)
}

test fn test_struct_literal() {
    let p = Point { x: 3, y: 4 }
    assert_eq(p.x + p.y, 7)
}
