import "stdlib/builtins_array.ny"
import "stdlib/vec.ny"

fn double(x: i32) -> i32 {
    return x * 2
}

fn main() {
    let v = Vec_i32_new()
    Array_push(v, 3)
    Array_push(v, 4)
    let out = Array_map(v, double)
    print(Vec_i32_get(out, 0))
    print(Vec_i32_get(out, 1))
}
