// Fast test variant (N=1000). Full benchmark uses sum_loop.ny (N=10_000_000).
fn main() {
    mut sum = 0
    mut i = 0
    let n = 1000
    while i < n {
        sum = sum + i
        i = i + 1
    }
    print(sum)
}
