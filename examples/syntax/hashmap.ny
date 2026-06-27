extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void
extern fn map_str_i32_get(m: ptr, key: string) -> i32
extern fn map_str_i32_contains(m: ptr, key: string) -> i32
extern fn map_str_i32_free(m: ptr) -> void

fn main() {
    let handle = map_str_i32_new()
    map_str_i32_insert(handle, "score", 100)
    print(map_str_i32_get(handle, "score"))
    print(map_str_i32_contains(handle, "score"))
    map_str_i32_free(handle)
}
