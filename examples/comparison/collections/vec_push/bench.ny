extern fn vec_i32_new() -> ptr
extern fn vec_i32_push(v: ptr, x: i32) -> void
extern fn vec_i32_pop(v: ptr) -> i32
extern fn vec_i32_get(v: ptr, i: i32) -> i32
extern fn vec_i32_len(v: ptr) -> i32
extern fn vec_i32_free(v: ptr) -> void

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let v = vec_i32_new()
    let mut i = 0
    while i < 500000 {
        vec_i32_push(v, i % 997)
        acc = (acc + vec_i32_len(v)) % 1000000007
        i = i + 1
    }
    vec_i32_free(v)

    print(blackbox_i32(acc))
}
