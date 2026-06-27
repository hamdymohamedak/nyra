// PGO training: branch-heavy dispatch (not a benchmark — profile diversity for --pgo).
extern fn blackbox_i32(x: i32) -> i32

fn main() {
    mut acc = 0
    let n = 8000000
    mut i = 0
    while i < n {
        let bucket = i % 17
        if bucket == 0 {
            acc = (acc + i) % 997
        } else if bucket < 5 {
            acc = (acc + bucket * 31) % 997
        } else if bucket < 11 {
            acc = (acc + bucket * 7) % 997
        } else {
            acc = (acc + (i % 4099)) % 997
        }
        i = i + 1
    }
    print(blackbox_i32(acc))
}
