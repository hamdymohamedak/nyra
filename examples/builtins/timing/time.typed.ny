fn main() -> void {
    time_start("work")
    let mut sum: i32 = 0
    for i in 0..1000 {
        sum = sum + i
    }
    time_end("work")
    print(sum)
}
