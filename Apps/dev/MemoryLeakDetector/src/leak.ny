import "../../shared/cli.ny"

fn LeakDetector_alloc_batch(count) {
    let mut v = StrVec_new()
    let mut i = 0
    while i < count {
        let row = strcat("leak-probe-", i32_to_string(i))
        v = v.push(row)
        alloc_track_note(strlen(row))
        i = i + 1
    }
    return v.len()
}

fn LeakDetector_run(args) {
    let listed = DevCli_paths(args)
    let n = DevPathList_len(listed)
    let mut batches = 3
    if n >= 1 {
        batches = str_to_i32(DevPathList_at(listed, 0))
    }
    if batches <= 0 {
        batches = 3
    }
    let mut per_batch = 200
    if n >= 2 {
        per_batch = str_to_i32(DevPathList_at(listed, 1))
    }
    if per_batch <= 0 {
        per_batch = 200
    }
    print(`ny-leak-detector: ${batches} batches x ${per_batch} StrVec pushes`)
    let mut b = 0
    while b < batches {
        let tag = i32_to_string(b)
        let label = strcat("batch-", tag)
        alloc_track_start(label)
        let rows = LeakDetector_alloc_batch(per_batch)
        blackbox_i32(rows)
        alloc_track_end(label)
        b = b + 1
    }
    print("RSS + alloc_track_note() estimates — not a full ASan replacement")
    return 0
}
