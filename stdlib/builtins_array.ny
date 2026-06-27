import "vec.ny"
import "iter/mod.ny"

// Array-style helpers over Vec_i32 handles.
fn Array_push(v: ptr, x: i32) -> ptr {
    Vec_i32_push(v, x)
    return v
}

fn Array_pop(v: ptr) -> i32 {
    return Vec_i32_pop(v)
}

fn Array_map(v: ptr, f: fn(i32) -> i32) -> ptr {
    return iter_map(v, f)
}

fn Array_filter(v: ptr, pred: fn(i32) -> i32) -> ptr {
    return iter_filter(v, pred)
}

fn Array_reduce(v: ptr, init: i32, reducer: fn(i32, i32) -> i32) -> i32 {
    let mut acc = init
    let n = Vec_i32_len(v)
    let mut i = 0
    while i < n {
        acc = reducer(acc, Vec_i32_get(v, i))
        i = i + 1
    }
    return acc
}

// Returns first matching value, or fallback if not found.
fn Array_find(v: ptr, pred: fn(i32) -> i32, fallback: i32) -> i32 {
    let n = Vec_i32_len(v)
    let mut i = 0
    while i < n {
        let x = Vec_i32_get(v, i)
        if pred(x) != 0 {
            return x
        }
        i = i + 1
    }
    return fallback
}
