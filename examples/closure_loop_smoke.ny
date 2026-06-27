import "stdlib/iter/mod.ny"

fn main() {
    let v = Vec_i32_from_range(1, 6)
    let mut i = 0
    let threshold = 2
    while i < 1 {
        let pred = (x) => if x > threshold { 1 } else { 0 }
        let filtered = iter_filter(v, pred)
        print(Vec_i32_len(filtered))
        i = i + 1
    }
}
