import "stdlib/builtins_array.ny"
import "stdlib/vec.ny"

fn main() {
    let v = Vec_i32_new()
    Array_push(v, 10)
    Array_push(v, 20)
    print(Array_pop(v))
    print(Vec_i32_len(v))
}
