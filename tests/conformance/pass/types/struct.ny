import "stdlib/testing.ny"

struct Point {
    x: i32
    y: i32
}

test fn conf_struct_literal_fields() {
    let p = Point { x: 3, y: 4 }
    assert_eq(p.x + p.y, 7)
}

test fn conf_struct_rebuild() {
    let p = Point { x: 1, y: 2 }
    let q = Point { x: 5, y: p.y }
    assert_eq(q.x, 5)
}
