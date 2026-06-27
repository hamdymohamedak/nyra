import "stdlib/testing.ny"
import "stdlib/json/mod.ny"
import "stdlib/vec_str.ny"

test fn test_json_nested_object() {
    let keys = Vec_str_new()
    let values = Vec_str_new()
    Vec_str_push(keys, "user")
    Vec_str_push(values, "{\"name\":\"Ada\",\"age\":42}")
    let json = encode_object(keys, values)
    Vec_str_free(keys)
    Vec_str_free(values)
    let inner = decode_object(json, "user")
    assert_str_eq(decode_string(inner, "name"), "Ada")
    assert_eq(decode_i32(inner, "age"), 42)
}

test fn test_json_bool_field() {
    let keys = Vec_str_new()
    let values = Vec_str_new()
    Vec_str_push(keys, "ok")
    Vec_str_push(values, "true")
    let json = encode_object(keys, values)
    Vec_str_free(keys)
    Vec_str_free(values)
    assert_eq(decode_bool(json, "ok"), 1)
}
