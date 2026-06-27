extern fn vec_i32_new() -> ptr
extern fn vec_i32_push(v: ptr, x: i32) -> void
extern fn vec_i32_get(v: ptr, i: i32) -> i32
extern fn vec_i32_len(v: ptr) -> i32
extern fn vec_i32_free(v: ptr) -> void

fn main() {
    let handle = vec_i32_new()
    vec_i32_push(handle, 10)
    vec_i32_push(handle, 20)
    print(vec_i32_len(handle))
    print(vec_i32_get(handle, 0))
    vec_i32_free(handle)
}
