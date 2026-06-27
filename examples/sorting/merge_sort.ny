// Iterative merge sort — exercises nested loops + array indexing (bounds-checked).
fn merge_sort(arr: [i32; 8], len: i32) -> void {
    let mut data = arr
    let mut width = 1
    while width < len {
        let mut start = 0
        while start < len {
            let mid = start + width
            if mid >= len {
                start = len
            } else {
                let end = mid + width
                let end2 = if end > len { len } else { end }
                let mut i = start
                let mut j = mid
                let mut k = start
                let mut tmp = [0; 8]
                while i < mid && j < end2 {
                    if data[i] <= data[j] {
                        tmp[k] = data[i]
                        i = i + 1
                    } else {
                        tmp[k] = data[j]
                        j = j + 1
                    }
                    k = k + 1
                }
                while i < mid {
                    tmp[k] = data[i]
                    i = i + 1
                    k = k + 1
                }
                while j < end2 {
                    tmp[k] = data[j]
                    j = j + 1
                    k = k + 1
                }
                let mut t = start
                while t < end2 {
                    data[t] = tmp[t]
                    t = t + 1
                }
                start = end2
            }
        }
        width = width * 2
    }
    let mut p = 0
    while p < len {
        print(data[p])
        p = p + 1
    }
}

fn main() -> void {
    merge_sort([38, 27, 43, 3, 9, 82, 10, 1], 8)
}
