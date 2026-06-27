// Compiler intrinsics: abs_i32, min_i32, max_i32, clamp_i32 (and abs/min/max on f64)
// are lowered to LLVM intrinsics at call sites — these bodies are reference stubs only.

fn abs_i32(x: i32) -> i32 {
    if x < 0 {
        return 0 - x
    }
    return x
}

fn abs_f64(x: f64) -> f64 {
    if x < 0.0 {
        return 0.0 - x
    }
    return x
}

fn min_i32(a: i32, b: i32) -> i32 {
    if a < b {
        return a
    }
    return b
}

fn max_i32(a: i32, b: i32) -> i32 {
    if a > b {
        return a
    }
    return b
}

fn clamp_i32(x: i32, lo: i32, hi: i32) -> i32 {
    if x < lo {
        return lo
    }
    if x > hi {
        return hi
    }
    return x
}

fn min_f64(a: f64, b: f64) -> f64 {
    if a < b {
        return a
    }
    return b
}

fn max_f64(a: f64, b: f64) -> f64 {
    if a > b {
        return a
    }
    return b
}

fn pow_i32(base: i32, exp: i32) -> i32 {
    if exp < 0 {
        return 0
    }
    let mut result = 1
    let mut i = 0
    while i < exp {
        result = result * base
        i = i + 1
    }
    return result
}

// Integer sqrt (Newton) — no libm required.
fn sqrt_i32(n: i32) -> i32 {
    if n <= 0 {
        return 0
    }
    let mut x = n
    let mut y = (x + 1) / 2
    while y < x {
        x = y
        y = (x + n / x) / 2
    }
    return x
}

extern fn sin_f64(x: f64) -> f64
extern fn cos_f64(x: f64) -> f64
extern fn atan2_f64(y: f64, x: f64) -> f64
extern fn tan_f64(x: f64) -> f64

fn sin(x) {
    return sin_f64(x)
}

fn cos(x) {
    return cos_f64(x)
}

fn atan2(y, x) {
    return atan2_f64(y, x)
}

fn tan(x) {
    return tan_f64(x)
}
