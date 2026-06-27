import "stdlib/serialize/mod.ny"
import "stdlib/vec_str.ny"

fn test_serialize_json_object() -> void {
    let keys = Vec_str_new()
    let values = Vec_str_new()
    Vec_str_push(keys, "name")
    Vec_str_push(values, "nyra")
    Vec_str_push(keys, "lang")
    Vec_str_push(values, "stable")
    let out = serialize(SerializeFormat.Json, keys, values)
    assert_str_eq(deserialize(SerializeFormat.Json, out, "name"), "nyra")
    assert_str_eq(deserialize(SerializeFormat.Json, out, "lang"), "stable")
    Vec_str_free(keys)
    Vec_str_free(values)
}

fn test_serialize_toml_object() -> void {
    let keys = Vec_str_new()
    let values = Vec_str_new()
    Vec_str_push(keys, "app")
    Vec_str_push(values, "nyra")
    let out = serialize(SerializeFormat.Toml, keys, values)
    assert_str_eq(deserialize(SerializeFormat.Toml, out, "app"), "nyra")
    Vec_str_free(keys)
    Vec_str_free(values)
}

fn main() -> i32 {
    test_serialize_json_object()
    test_serialize_toml_object()
    return 0
}
