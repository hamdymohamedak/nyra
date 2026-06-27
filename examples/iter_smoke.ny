import "stdlib/iter/mod.ny"

fn main() {
    let v = Vec_i32_from_range(1, 6)
    let evens = iter_filter(v, (x: i32) => if x % 2 == 0 { 1 } else { 0 })
    let doubled = iter_map(evens, (x: i32) => x * 2)
    print(Vec_i32_len(doubled))
    print(Vec_i32_get(doubled, 0))
}
