fn test_json_decode_i32() -> void {
    let json = "{\"count\":42,\"name\":\"nyra\"}"
    assert_eq(decode_i32(json, "count"), 42)
}

fn test_json_decode_string() -> void {
    let json = "{\"count\":42,\"name\":\"nyra\"}"
    assert_str_eq(decode_string(json, "name"), "nyra")
}

fn test_json_encode_i32() -> void {
    let out = encode_i32("n", 7)
    assert_str_eq(out, "{\"n\":7}")
    assert_eq(decode_i32(out, "n"), 7)
}

fn main() -> i32 {
    test_json_decode_i32()
    test_json_decode_string()
    test_json_encode_i32()
    return 0
}
