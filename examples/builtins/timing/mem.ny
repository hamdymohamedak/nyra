fn main() {
    mem_start("work")
    let mut sum = 0
    for i in 0..1000 {
        sum = sum + i
    }
    mem_end("work")
    print(sum)
}
