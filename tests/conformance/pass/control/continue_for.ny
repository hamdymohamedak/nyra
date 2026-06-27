fn main() {
    let mut sum = 0
    for i in 1..6 {
        if i == 3 {
            continue
        }
        sum = sum + i
    }
    assert_eq(sum, 11)
}
