extern fn rt_affinity_set_thread_cpu(core_index: i32) -> i32
extern fn rt_affinity_get_thread_cpu() -> i32

// Pin the current OS thread to a logical CPU core (0-based index).
fn affinity_set_thread_cpu(core_index: i32) -> i32 {
    return rt_affinity_set_thread_cpu(core_index)
}

fn affinity_get_thread_cpu() -> i32 {
    return rt_affinity_get_thread_cpu()
}
