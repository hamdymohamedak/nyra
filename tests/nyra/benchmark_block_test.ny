extern fn blackbox_i32(x: i32) -> i32

test fn test_benchmark_block() {
    benchmark {
        let mut sum = 0
        for i in 0..100 {
            sum = blackbox_i32(sum + i)
        }
        blackbox_i32(sum)
    }
}
