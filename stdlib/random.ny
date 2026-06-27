import "vec.ny"

extern fn rand_i32() -> i32
extern fn rand_range(min_val: i32, max_val: i32) -> i32
extern fn rand_f64() -> f64

fn random() -> i32 {
    return rand_i32()
}

fn random_range(min_val: i32, max_val: i32) -> i32 {
    return rand_range(min_val, max_val)
}

fn random_f64() {
    return rand_f64()
}

fn shuffle_pick(v: ptr) -> i32 {
    let n = vec_len(v)
    if n <= 0 {
        return 0
    }
    let idx = rand_range(0, n - 1)
    return vec_get(v, idx)
}
