// run-stdout: ok
// Auto-prelude: stdlib symbols available without import.

fn main() {
    let mut v = Vec_i32_new()
    v = vec_push(v, 1)
    if vec_len(v) == 1 {
        print("ok")
    }
}
