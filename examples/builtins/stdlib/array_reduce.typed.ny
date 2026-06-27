import "stdlib/builtins_array.ny"
import "stdlib/vec.ny"

fn add(acc: i32, x: i32) -> i32 {
    return acc + x
}

fn main() -> void {
    let v: ptr = Vec_i32_new()
    Array_push(v, 10)
    Array_push(v, 20)
    print(Array_reduce(v, 0, add))
}
