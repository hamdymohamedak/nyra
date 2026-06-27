fn main() {
    time_start("work")
    let mut sum = 0
    for i in 0..1000 {
        sum = sum + i
    }
    time_end("work")
    print(sum)
}
