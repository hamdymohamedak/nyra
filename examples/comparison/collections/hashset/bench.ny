extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void
extern fn map_str_i32_get(m: ptr, key: string) -> i32
extern fn map_str_i32_contains(m: ptr, key: string) -> i32
extern fn map_str_i32_free(m: ptr) -> void
extern fn i32_to_string(n: i32) -> string

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let m = map_str_i32_new()
    let mut i = 0
    while i < 200000 {
        let kk = i % 10000
        map_str_i32_insert(m, i32_to_string(kk), 1)
        acc = (acc + map_str_i32_contains(m, i32_to_string(kk))) % 1000000007
        i = i + 1
    }
    map_str_i32_free(m)

    print(blackbox_i32(acc))
}
