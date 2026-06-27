// Result propagation without `?` — repetitive match is required today.
// Runnable: nyra run examples/result_propagate_verbose.ny
//
// With real Result payloads, every fallible step needs explicit error handling.
// Languages with `?` collapse this to a single line per step; Nyra does not ship `?` yet.

enum Result_i32_i32 {
    Ok(i32),
    Err(i32),
}

fn main() {
    let n = match Result_i32_i32.Ok(1) {
        Result_i32_i32.Ok(v1) => match Result_i32_i32.Ok(v1 + 1) {
            Result_i32_i32.Ok(v2) => match Result_i32_i32.Ok(v2 * 2) {
                Result_i32_i32.Ok(v3) => v3
                Result_i32_i32.Err(e) => e
            }
            Result_i32_i32.Err(e) => e
        }
        Result_i32_i32.Err(e) => e
    }
    print(n)

    // With fallible helpers returning Result, you would write one match per call:
    //
    //   let r1 = read_config()
    //   let cfg = match r1 {
    //       Result.Ok(v) => v
    //       Result.Err(e) => default_or_abort(e)
    //   }
    //   let r2 = connect(cfg)
    //   let conn = match r2 { ... }
    //
    // Prefer small bind_* helpers or unwrap_* from stdlib/result.ny until `?` lands.
}
