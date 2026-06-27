import "math.ny"

extern fn rand_range(min_val: i32, max_val: i32) -> i32

// Math-style helpers (JS-like naming adapted to Nyra function names).
fn Math_round(x: i32) -> i32 {
    return x
}

fn Math_floor(x: i32) -> i32 {
    return x
}

fn Math_ceil(x: i32) -> i32 {
    return x
}

// Returns a pseudo-random f64 in [0, 1).
fn Math_random() -> f64 {
    let n = rand_range(0, 999999)
    return n / 1000000.0
}

fn Math_max(a: i32, b: i32) -> i32 {
    return max_i32(a, b)
}

fn Math_min(a: i32, b: i32) -> i32 {
    return min_i32(a, b)
}
