// run-stdout: 1
// run-stdout: 2
// run-stdout: 3
fn main() {
    let nums = [3, 1, 2]
    let sorted = nums.sort_by((a, b) => a - b)
    for n in sorted {
        print(n)
    }
}
