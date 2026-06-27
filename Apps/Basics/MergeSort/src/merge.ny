fn Arr_print(arr: [i32; 8], len){
    let mut i = 0
    while i < len {
        print(arr[i])
        i = i + 1
    }
}

fn MergeSort_run(){
    let mut arr = [38, 27, 43, 3, 9, 82, 10, 1]
    let len = 8
    print("merge sort (iterative + generics):")
    time_start("merge")
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
                    if arr[i] <= arr[j] {
                        tmp[k] = arr[i]
                        i = i + 1
                    } else {
                        tmp[k] = arr[j]
                        j = j + 1
                    }
                    k = k + 1
                }
                while i < mid {
                    tmp[k] = arr[i]
                    i = i + 1
                    k = k + 1
                }
                while j < end2 {
                    tmp[k] = arr[j]
                    j = j + 1
                    k = k + 1
                }
                let mut t = start
                while t < end2 {
                    arr[t] = tmp[t]
                    t = t + 1
                }
                start = end2
            }
        }
        width = width * 2
    }
    time_end("merge")
    Arr_print(arr, len)
}
