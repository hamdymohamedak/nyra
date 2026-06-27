fn main() -> void {
    time_start("loop")

    let mut sum = 0
    for i in 0..100000 {
        sum = sum + i
    }

    time_end("loop")
    print(sum)
}
