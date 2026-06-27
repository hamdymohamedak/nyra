fn main() {
    let mut sum = 0
    let mut i = 0
    while i < 5 {
        i = i + 1
        if i == 3 {
            continue
        }
        sum = sum + i
    }
    print(sum)
}
