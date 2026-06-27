fn main() -> i32 {
    let json = "{\"count\":42,\"name\":\"nyra\"}"
    print(i32_to_string(decode_i32(json, "count")))
    print(decode_string(json, "name"))
    return 0
}
