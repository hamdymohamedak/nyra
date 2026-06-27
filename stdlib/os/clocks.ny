extern fn rt_clock_rdtsc() -> i64
extern fn rt_clock_monotonic_ns() -> i64

// CPU cycle counter: RDTSC on x86_64, cntvct on ARM64, else monotonic ns.
fn clock_rdtsc() -> i64 {
    return rt_clock_rdtsc()
}

fn clock_monotonic_ns() -> i64 {
    return rt_clock_monotonic_ns()
}

fn clock_elapsed_ns(start: i64) -> i64 {
    let end = rt_clock_monotonic_ns()
    return end - start
}
