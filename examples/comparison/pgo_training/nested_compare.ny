// PGO training: nested compares and early exits (branch predictor exercise).
extern fn blackbox_i32(x: i32) -> i32

fn main() {
    mut acc = 0
    let n = 6000000
    mut i = 0
    while i < n {
        let x = i % 997
        if x < 100 {
            if x < 10 {
                acc = (acc + 1) % 997
            } else {
                acc = (acc + x) % 997
            }
        } else if x < 500 {
            acc = (acc + (x * 3)) % 997
        } else {
            acc = (acc + (x % 31)) % 997
        }
        i = i + 1
    }
    print(blackbox_i32(acc))
}
