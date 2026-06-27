// run-stdout: 200
fn main() {
    let mut count = 0
    for i in 0..10 {
        for j in 0..20 {
            count = count + 1
        }
    }
    print(count)
}
