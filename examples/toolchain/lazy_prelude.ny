// Lazy auto-prelude: only `vec.ny` (and its imports) merge — not the full stdlib.
// Compare IR size:
//   nyra build examples/toolchain/lazy_prelude.ny --release -o lazy_ok
//   nyra build examples/toolchain/no_prelude.ny --release --no-prelude -o slim

fn main() {
    let mut v = Vec_i32_new()
    v = vec_push(v, 42)
    if vec_len(v) == 1 {
        print("lazy prelude ok")
    }
}
