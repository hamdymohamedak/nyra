// Move-safe Vec<LabelRow> (typed) — nyra run examples/collections/vec_reloc.typed.ny
import "stdlib/collections/vec_pod.ny"

struct LabelRow {
    label: string
    count: i32
}

fn main() -> void {
    let mut rows: Vec<LabelRow> = Vec_LabelRow_new()
    rows = Vec_LabelRow_push(rows, LabelRow { label: "one", count: 1 })
    rows = Vec_LabelRow_push(rows, LabelRow { label: "two", count: 2 })
    print(Vec_LabelRow_len(rows))
    let row = Vec_LabelRow_get(rows, 1)
    print(row.count)
    Vec_LabelRow_free(rows)
}
