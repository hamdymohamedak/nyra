fn main() {
    log_info("stdlib demo")

    let mut users = Vec_i32_new()
    users = vec_push(users, 1)
    users = vec_push(users, 2)
    print(vec_len(users))

    let mut map = HashMap_str_i32_new()
    map = HashMap_str_i32_insert(map, "age", 20)
    print(HashMap_str_i32_get(map, "age"))

    let name = "hamdy"
    print(str_to_upper(name))

    print(pow_i32(2, 3))

    let start = Instant_now()
    sleep(5)
    print(start.elapsed_ms())

    let body = encode_field("name", "nyra")
    print(decode_string(body, "name"))
}
