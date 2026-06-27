fn main() -> void {
    mem_start("sum loop")

    let mut sum = 0
    for i in 0..100_000 {
        sum = sum + i
    }

    mem_end("sum loop")
    print(sum)
}
