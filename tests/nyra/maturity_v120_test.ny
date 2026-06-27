// Maturity improvements v1.23 — Vec<string>, RowVec, Matrix2D, serde str arrays
import "stdlib/testing.ny"
import "stdlib/json/mod.ny"
import "stdlib/vec_str.ny"
import "stdlib/collections/matrix2d.ny"
import "stdlib/collections/row_vec.ny"

test fn test_vec_string_generic_syntax() {
    let mut tags: Vec<string> = Vec_string_new()
    tags = Vec_string_push(tags, "a")
    tags = Vec_string_push(tags, "b")
    assert_eq(Vec_string_len(tags), 2)
    assert_str_eq(Vec_string_get(tags, 0), "a")
    Vec_string_free(tags)
}

test fn test_row_vec_move_strings() {
    let mut rv = RowVec_new()
    rv = RowVec_push(rv, "x", 1)
    rv = RowVec_push(rv, "y", 2)
    assert_eq(RowVec_len(rv), 2)
    assert_str_eq(RowVec_label(rv, 1), "y")
    assert_eq(RowVec_count(rv, 1), 2)
    RowVec_free(rv)
}

test fn test_json_str_array_roundtrip() {
    let mut tags = StrVec_new()
    tags = tags.push("alpha")
    tags = tags.push("beta")
    let json = json_encode_str_array(StrVec_raw(tags))
    let h = json_decode_str_array(json)
    assert_eq(Vec_str_len(h), 2)
    assert_str_eq(Vec_str_get(h, 1), "beta")
    Vec_str_free(h)
}

struct TagList {
    name: string
}

test fn test_struct_serde_with_name() {
    let s = TagList { name: "demo" }
    let json = TagList_json_encode(s)
    let s2 = TagList_json_decode(json)
    assert_str_eq(s2.name, "demo")
}

test fn test_matrix2d_put_get() {
    let mut m = Matrix2D_new(2, 3)
    m = m.put(0, 1, 7)
    m = m.put(1, 2, 9)
    assert_eq(m.get(0, 1), 7)
    assert_eq(m.get(1, 2), 9)
    assert_eq(m.rows(), 2)
    assert_eq(m.cols(), 3)
    Matrix2D_free(m)
}
