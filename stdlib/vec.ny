extern fn vec_i32_new() -> ptr
extern fn vec_i32_push(v: ptr, x: i32) -> void
extern fn vec_i32_get(v: ptr, i: i32) -> i32
extern fn vec_i32_set(v: ptr, i: i32, value: i32) -> void
extern fn vec_i32_len(v: ptr) -> i32
extern fn vec_i32_pop(v: ptr) -> i32
extern fn vec_i32_free(v: ptr) -> void

fn Vec_i32_new() -> ptr {
    return vec_i32_new()
}

fn Vec_i32_push(v: ptr, x: i32) -> void {
    vec_i32_push(v, x)
}

fn Vec_i32_get(v: ptr, i: i32) -> i32 {
    return vec_i32_get(v, i)
}

fn Vec_i32_set(v: ptr, i: i32, value: i32) -> void {
    vec_i32_set(v, i, value)
}

fn Vec_i32_len(v: ptr) -> i32 {
    return vec_i32_len(v)
}

fn Vec_i32_pop(v: ptr) -> i32 {
    return vec_i32_pop(v)
}

fn Vec_i32_free(v: ptr) -> void {
    vec_i32_free(v)
}

fn Vec_i32_from_range(start: i32, end: i32) -> ptr {
    let v = vec_i32_new()
    let mut i = start
    while i < end {
        vec_i32_push(v, i)
        i = i + 1
    }
    return v
}

// Free helpers for stdlib internals (ptr-backed Vec_i32 handles).
fn vec_len(v: ptr) -> i32 {
    return Vec_i32_len(v)
}

fn vec_get(v: ptr, i: i32) -> i32 {
    return Vec_i32_get(v, i)
}

fn vec_push(v: ptr, x: i32) -> ptr {
    Vec_i32_push(v, x)
    return v
}
