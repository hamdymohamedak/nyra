extern fn time_start(label: string) -> void
extern fn time_end(label: string) -> void
extern fn blackbox_i32(x: i32) -> i32

fn bench_loop(label: string, iterations: i32) -> i32 {
    time_start(label)
    let mut i = 0
    let mut acc = 0
    while i < iterations {
        acc = blackbox_i32(acc + i)
        i = i + 1
    }
    time_end(label)
    return acc
}

fn bench_once(label: string) -> void {
    time_start(label)
    time_end(label)
}
