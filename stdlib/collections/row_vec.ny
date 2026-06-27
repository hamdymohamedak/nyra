// Parallel-column vector for structs with string + scalar fields (Move-safe rows).
import "../vec_str.ny"
import "../vec.ny"

struct RowVec {
    labels: ptr
    counts: ptr
}

fn RowVec_new() -> RowVec {
    return RowVec { labels: Vec_str_new(), counts: Vec_i32_new() }
}

fn RowVec_push(rv: RowVec, label: string, count: i32) -> RowVec {
    Vec_str_push(rv.labels, label)
    Vec_i32_push(rv.counts, count)
    return rv
}

fn RowVec_len(rv: RowVec) -> i32 {
    return Vec_str_len(rv.labels)
}

fn RowVec_label(rv: RowVec, index: i32) -> string {
    return Vec_str_get(rv.labels, index)
}

fn RowVec_count(rv: RowVec, index: i32) -> i32 {
    return Vec_i32_get(rv.counts, index)
}

fn RowVec_free(rv: RowVec) -> void {
    Vec_str_free(rv.labels)
    Vec_i32_free(rv.counts)
}
