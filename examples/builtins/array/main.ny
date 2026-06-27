import "stdlib/builtins_array.ny"
import "stdlib/vec.ny"

fn is_even(x: i32) -> i32 {
    if x % 2 == 0 {
        return 1
    }
    return 0
}

fn mul10(x: i32) -> i32 {
    return x * 10
}

fn sum(acc: i32, x: i32) -> i32 {
    return acc + x
}

fn main() {
    let v = Vec_i32_new()
    Array_push(v, 1)
    Array_push(v, 2)
    Array_push(v, 3)
    Array_push(v, 4)

    let mapped = Array_map(v, mul10)
    let evens = Array_filter(v, is_even)
    let total = Array_reduce(v, 0, sum)
    let found = Array_find(v, is_even, -1)

    print(Vec_i32_len(mapped))
    print(Vec_i32_len(evens))
    print(total)
    print(found)
    print(Array_pop(v))
}
