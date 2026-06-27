// run-stdout: 3
fn main() {
    let mut count = 0
    for i in 0..3 {
        for j in 0..1 {
            count = count + 1
        }
    }
    print(count)
}
