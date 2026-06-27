fn main() -> void {
    mem_start("work")
    let mut sum: i32 = 0
    for i in 0..1000 {
        sum = sum + i
    }
    mem_end("work")
    print(sum)
}
