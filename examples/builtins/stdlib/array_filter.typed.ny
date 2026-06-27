import "stdlib/builtins_array.ny"
import "stdlib/vec.ny"

fn is_even(x: i32) -> i32 {
    if x % 2 == 0 {
        return 1
    }
    return 0
}

fn main() -> void {
    let v: ptr = Vec_i32_new()
    Array_push(v, 1)
    Array_push(v, 2)
    Array_push(v, 3)
    let evens: ptr = Array_filter(v, is_even)
    print(Vec_i32_len(evens))
    print(Vec_i32_get(evens, 0))
}
