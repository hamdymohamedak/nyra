import "../../../stdlib/vec.ny"

fn main() {
    let mut v = Vec_i32_new()
    v = vec_push(v, 1)
    print(vec_len(v))
}
