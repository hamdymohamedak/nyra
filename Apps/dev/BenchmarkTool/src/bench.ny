import "../../shared/cli.ny"

fn BenchTool_fib(n) {
    if n <= 1 {
        return n
    }
    return BenchTool_fib(n - 1) + BenchTool_fib(n - 2)
}

fn BenchTool_work(iterations) {
    let mut acc = 0
    let mut i = 0
    while i < iterations {
        acc = blackbox_i32(acc + BenchTool_fib(12))
        i = i + 1
    }
    return acc
}

fn BenchTool_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    let mut iterations = 5
    if n >= 1 {
        iterations = str_to_i32(DevPathList_at(listed, 0))
    }
    if iterations <= 0 {
        iterations = 5
    }
    print(`ny-bench: fib(12) x ${iterations} (blackbox_i32)`)
    let acc = bench_loop("fib-loop", iterations)
    blackbox_i32(acc)
    benchmark {
        BenchTool_work(1)
    }
    print("tip: `benchmark { }` block + bench_loop() from prelude")
    return 0
}
