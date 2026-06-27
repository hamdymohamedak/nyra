// run-stdout: 100
fn main() {
    let mut count = 0
    for i in 0..10 {
        for j in 0..10 {
            count = count + 1
        }
    }
    print(count)
}
