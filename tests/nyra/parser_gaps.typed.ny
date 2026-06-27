import "stdlib/collections/vec_pod.ny"
import "stdlib/parser/combinator.ny"
import "stdlib/map.ny"

struct Point {
    x: i32
    y: i32
}

fn make_point() -> Point {
    return Point { x: 3, y: 4 }
}

test fn test_continue_multi_mut() -> void {
    let mut i: i32 = 0
    let mut sum: i32 = 0
    while i < 5 {
        i = i + 1
        if i == 3 {
            continue
        }
        sum = sum + i
    }
    assert_eq(sum, 12)
}

test fn test_hashmap_generic_syntax() -> void {
    let mut m: HashMap<string, i32> = HashMap_str_i32_new()
    m = m.insert("x", 7)
    assert_eq(m.get("x"), 7)
}

test fn test_struct_return_helper() -> void {
    let p: Point = make_point()
    assert_eq(p.x, 3)
    assert_eq(p.y, 4)
}

test fn test_vec_pod_point() -> void {
    let mut v: Vec<Point> = Vec_Point_new()
    v = Vec_Point_push(v, Point { x: 1, y: 2 })
    assert_eq(Vec_Point_len(v), 1)
    let p: Point = Vec_Point_get(v, 0)
    assert_eq(p.x, 1)
    Vec_Point_free(v)
}

test fn test_comb_or_literal() -> void {
    let cur = ParseCursor_new("null", "t.ny")
    let packed = Comb_or_literal(cur, "null", "true")
    assert_str_eq(Comb_ok_value(packed), "null")
}
