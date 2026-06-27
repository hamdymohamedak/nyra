// run-stdout: 50
fn main() {
    let mut count = 0
    for i in 0..5 {
        for j in 0..10 {
            count = count + 1
        }
    }
    print(count)
}
