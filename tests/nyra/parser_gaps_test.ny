import "stdlib/parser/sourceloc.ny"
import "stdlib/unicode/iter.ny"
import "stdlib/strings/split.ny"
import "stdlib/collections/kv_vec.ny"
import "stdlib/collections/vec_pod.ny"
import "stdlib/parser/combinator.ny"
import "stdlib/parser/ast_row.ny"
import "stdlib/map.ny"

struct Point {
    x: i32
    y: i32
}

fn make_point() {
    return Point { x: 3, y: 4 }
}

test fn test_continue_while() {
    let mut i = 0
    while i < 5 {
        i = i + 1
        if i == 3 {
            continue
        }
    }
    assert_eq(i, 5)
}

test fn test_continue_multi_mut() {
    let mut i = 0
    let mut sum = 0
    while i < 5 {
        i = i + 1
        if i == 3 {
            continue
        }
        sum = sum + i
    }
    assert_eq(sum, 12)
}

test fn test_substring_reuse() {
    let s = "abcdef"
    let a = substring(s, 0, 2)
    let b = substring(s, 2, 2)
    assert_str_eq(a, "ab")
    assert_str_eq(b, "cd")
}

test fn test_source_loc_format() {
    let loc = SourceLoc_new("main.ny", 10, 4)
    let text = SourceLoc_format(loc)
    assert_eq(strstr_pos(text, "main.ny"), 0)
}

test fn test_utf8_codepoint_count() {
    assert_eq(utf8_codepoint_count("a"), 1)
    assert_eq(utf8_codepoint_count("مرحبا"), 5)
}

test fn test_string_split_quoted() {
    let parts = String_split_quoted("a,\"b,c\",d", ",")
    assert_eq(parts.len(), 3)
    assert_str_eq(parts.get(1), "\"b,c\"")
}

test fn test_kv_vec_push() {
    let mut kv = KvVec_new()
    kv = KvVec_push(kv, "k", "v")
    assert_eq(KvVec_len(kv), 1)
    assert_str_eq(KvVec_get_key(kv, 0), "k")
    assert_str_eq(KvVec_get_value(kv, 0), "v")
}

test fn test_hashmap_keys() {
    let mut m = HashMap_str_str_new()
    m = m.insert("a", "1")
    m = m.insert("b", "2")
    let keys = m.keys()
    assert_eq(keys.len(), 2)
}

test fn test_hashmap_generic_syntax() {
    let mut m: HashMap<string, i32> = HashMap_str_i32_new()
    m = m.insert("x", 7)
    assert_eq(m.get("x"), 7)
}

test fn test_struct_return_helper() {
    let p = make_point()
    assert_eq(p.x, 3)
    assert_eq(p.y, 4)
}

test fn test_vec_pod_point() {
    let mut v: Vec<Point> = Vec_Point_new()
    v = Vec_Point_push(v, Point { x: 1, y: 2 })
    v = Vec_Point_push(v, Point { x: 3, y: 4 })
    assert_eq(Vec_Point_len(v), 2)
    let p = Vec_Point_get(v, 1)
    assert_eq(p.x, 3)
    Vec_Point_free(v)
}

test fn test_comb_or_literal() {
    let cur = ParseCursor_new("true false", "t.ny")
    let packed = Comb_or_literal(cur, "true", "false")
    assert_str_eq(Comb_ok_value(packed), "true")
}

test fn test_comb_many() {
    let cur = ParseCursor_new("aa bb", "m.ny")
    let parts = Comb_many(cur, 2)
    assert_eq(parts.len(), 2)
}

test fn test_ast_row() {
    let mut row = AstRow_new()
    row = AstRow_push(row, "ident", "foo")
    assert_eq(AstRow_len(row), 1)
    assert_str_eq(AstRow_kind(row, 0), "ident")
    assert_str_eq(AstRow_text(row, 0), "foo")
}
