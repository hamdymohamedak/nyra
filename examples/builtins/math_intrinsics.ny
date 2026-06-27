// Compiler math intrinsics: no stdlib prelude required (--no-prelude friendly).
// Build: nyra build examples/builtins/math_intrinsics.ny --release --no-prelude -o math_intrinsics
// Run:   ./target/release/math_intrinsics

fn main() {
    let a = abs_i32(-42)
    let b = min_i32(3, 7)
    let c = max_i32(3, 7)
    let d = clamp_i32(15, 0, 10)
    print(a)
    print(b)
    print(c)
    print(d)
    let x = abs(-5)
    print(x)
}
