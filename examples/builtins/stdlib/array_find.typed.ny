import "stdlib/builtins_array.ny"
import "stdlib/vec.ny"

fn is_two(x: i32) -> i32 {
    if x == 2 {
        return 1
    }
    return 0
}

fn main() -> void {
    let v: ptr = Vec_i32_new()
    Array_push(v, 1)
    Array_push(v, 2)
    print(Array_find(v, is_two, -1))
}
