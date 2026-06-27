import "../../shared/cli.ny"

fn Profiler_hot_loop(n) {
    let mut acc = 0
    let mut i = 0
    while i < n {
        acc = blackbox_i32(acc + i * i)
        i = i + 1
    }
    return acc
}

fn Profiler_alloc_work(n) {
    let mut v = StrVec_new()
    let mut i = 0
    while i < n {
        v = v.push(strcat("row-", i32_to_string(i)))
        i = i + 1
    }
    return v.len()
}

fn Profiler_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    let mut size = 5000
    if n >= 1 {
        size = str_to_i32(DevPathList_at(listed, 0))
    }
    if size <= 0 {
        size = 5000
    }
    print(`ny-profiler: size=${size}`)
    let session = profile_start("total")
    profile_time("cpu-only")
    Profiler_hot_loop(size)
    profile_memory("alloc-only")
    let rows = Profiler_alloc_work(size / 10)
    blackbox_i32(rows)
    session.stop()
    print("tip: profile_start/stop uses time_start + mem_start (RSS delta)")
    print("gap: no call-stack sampling, no flame graph export, no per-fn LLVM counters")
    return 0
}
