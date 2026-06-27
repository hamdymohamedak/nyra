import "../vec.ny"

fn iter_filter(v: ptr, pred: fn(i32) -> i32) -> ptr {
    let out = vec_i32_new()
    let n = vec_i32_len(v)
    let mut i = 0
    while i < n {
        let x = vec_i32_get(v, i)
        if pred(x) != 0 {
            vec_i32_push(out, x)
        }
        i = i + 1
    }
    return out
}

fn iter_map(v: ptr, f: fn(i32) -> i32) -> ptr {
    let out = vec_i32_new()
    let n = vec_i32_len(v)
    let mut i = 0
    while i < n {
        let x = vec_i32_get(v, i)
        vec_i32_push(out, f(x))
        i = i + 1
    }
    return out
}

fn iter_collect(v: ptr) -> ptr {
    return v
}

fn vec_filter_gt(v: ptr, threshold: i32) -> ptr {
    return iter_filter(v, (x: i32) => if x > threshold { 1 } else { 0 })
}

fn vec_map_add(v: ptr, delta: i32) -> ptr {
    return iter_map(v, (x: i32) => x + delta)
}

fn vec_reduce_sum(v: ptr) -> i32 {
    let mut acc = 0
    let n = vec_i32_len(v)
    let mut i = 0
    while i < n {
        acc = acc + vec_i32_get(v, i)
        i = i + 1
    }
    return acc
}
