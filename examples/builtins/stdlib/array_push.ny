import "stdlib/builtins_array.ny"
import "stdlib/vec.ny"

fn main() {
    let v = Vec_i32_new()
    Array_push(v, 1)
    Array_push(v, 2)
    print(Vec_i32_len(v))
}
