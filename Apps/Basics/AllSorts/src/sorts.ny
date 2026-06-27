fn Arr_copy(src: [i32; 8], len){
    let mut out = [0; 8]
    let mut i = 0
    while i < len {
        out[i] = src[i]
        i = i + 1
    }
    return out
}

fn Arr_print(label, arr: [i32; 8], len){
    print(label)
    let mut i = 0
    while i < len {
        print(arr[i])
        i = i + 1
    }
}

fn Sort_bubble_demo(input: [i32; 8], len){
    let mut arr = input
    let mut n = len
    while n > 1 {
        let mut j = 0
        while j < n - 1 {
            if arr[j] > arr[j + 1] {
                let tmp = arr[j]
                arr[j] = arr[j + 1]
                arr[j + 1] = tmp
            }
            j = j + 1
        }
        n = n - 1
    }
    Arr_print("bubble:", arr, len)
}

fn Sort_selection_demo(input: [i32; 8], len){
    let mut arr = input
    let mut i = 0
    while i < len {
        let mut min_i = i
        let mut j = i + 1
        while j < len {
            if arr[j] < arr[min_i] {
                min_i = j
            }
            j = j + 1
        }
        if min_i != i {
            let tmp = arr[i]
            arr[i] = arr[min_i]
            arr[min_i] = tmp
        }
        i = i + 1
    }
    Arr_print("selection:", arr, len)
}

fn Sort_insertion_demo(input: [i32; 8], len){
    let mut arr = input
    let mut i = 1
    while i < len {
        let key = arr[i]
        let mut j = i - 1
        while j >= 0 && arr[j] > key {
            arr[j + 1] = arr[j]
            j = j - 1
        }
        arr[j + 1] = key
        i = i + 1
    }
    Arr_print("insertion:", arr, len)
}

fn Sort_merge_demo(input: [i32; 8], len){
    let mut arr = input
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
    Arr_print("merge:", arr, len)
}

fn Sort_quick_demo(input: [i32; 8], len){
    let mut arr = input
    let mut stack = Vec_i32_new()
    Vec_i32_push(stack, 0)
    Vec_i32_push(stack, len - 1)
    while Vec_i32_len(stack) > 0 {
        let hi = Vec_i32_pop(stack)
        let lo = Vec_i32_pop(stack)
        if lo < hi {
            let pivot = arr[hi]
            let mut i = lo - 1
            let mut j = lo
            while j < hi {
                if arr[j] <= pivot {
                    i = i + 1
                    let tmp = arr[i]
                    arr[i] = arr[j]
                    arr[j] = tmp
                }
                j = j + 1
            }
            let tmp2 = arr[i + 1]
            arr[i + 1] = arr[hi]
            arr[hi] = tmp2
            let p = i + 1
            Vec_i32_push(stack, lo)
            Vec_i32_push(stack, p - 1)
            Vec_i32_push(stack, p + 1)
            Vec_i32_push(stack, hi)
        }
    }
    Vec_i32_free(stack)
    Arr_print("quick:", arr, len)
}

fn Sort_heap_demo(input: [i32; 8], len){
    let mut arr = input
    let mut i = len / 2 - 1
    while i >= 0 {
        let mut root = i
        let mut done = 0
        while done == 0 {
            let largest = root
            let left = 2 * root + 1
            let right = 2 * root + 2
            let mut target = largest
            if left < len && arr[left] > arr[target] {
                target = left
            }
            if right < len && arr[right] > arr[target] {
                target = right
            }
            if target == root {
                done = 1
            } else {
                let tmp = arr[root]
                arr[root] = arr[target]
                arr[target] = tmp
                root = target
            }
        }
        i = i - 1
    }
    let mut end = len - 1
    while end > 0 {
        let tmp = arr[0]
        arr[0] = arr[end]
        arr[end] = tmp
        let mut root = 0
        let mut done2 = 0
        while done2 == 0 {
            let mut target = root
            let left = 2 * root + 1
            let right = 2 * root + 2
            if left < end && arr[left] > arr[target] {
                target = left
            }
            if right < end && arr[right] > arr[target] {
                target = right
            }
            if target == root {
                done2 = 1
            } else {
                let tmp2 = arr[root]
                arr[root] = arr[target]
                arr[target] = tmp2
                root = target
            }
        }
        end = end - 1
    }
    Arr_print("heap:", arr, len)
}

fn AllSorts_run(){
    let input = [10, 1, 2, 8, 5, 3, 7, 4]
    let len = 8
    print("=== All Sorts ===")
    Arr_print("input:", input, len)
    time_start("bubble")
    Sort_bubble_demo(Arr_copy(input, len), len)
    time_end("bubble")
    time_start("selection")
    Sort_selection_demo(Arr_copy(input, len), len)
    time_end("selection")
    time_start("insertion")
    Sort_insertion_demo(Arr_copy(input, len), len)
    time_end("insertion")
    time_start("merge")
    Sort_merge_demo(Arr_copy(input, len), len)
    time_end("merge")
    time_start("quick")
    Sort_quick_demo(Arr_copy(input, len), len)
    time_end("quick")
    time_start("heap")
    Sort_heap_demo(Arr_copy(input, len), len)
    time_end("heap")
}
