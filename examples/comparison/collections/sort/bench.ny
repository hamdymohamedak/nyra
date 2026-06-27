extern fn vec_i32_new() -> ptr
extern fn vec_i32_push(v: ptr, x: i32) -> void
extern fn vec_i32_pop(v: ptr) -> i32
extern fn vec_i32_get(v: ptr, i: i32) -> i32
extern fn vec_i32_len(v: ptr) -> i32
extern fn vec_i32_free(v: ptr) -> void

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let v = vec_i32_new()
    let mut i = 0
    while i < 50000 {
        let t = 50000 - i
        vec_i32_push(v, t % 997)
        i = i + 1
    }
    let n = vec_i32_len(v)
    let mut gap = n / 2
    while gap > 0 {
        let mut j = gap
        while j < n {
            let key = vec_i32_get(v, j)
            let mut k = j
            while k >= gap && vec_i32_get(v, k - gap) > key {
                k = k - gap
            }
            j = j + 1
        }
        gap = gap / 2
    }
    let mut t = 0
    while t < n {
        acc = (acc + vec_i32_get(v, t)) % 1000000007
        t = t + 1
    }
    vec_i32_free(v)

    print(blackbox_i32(acc))
}
