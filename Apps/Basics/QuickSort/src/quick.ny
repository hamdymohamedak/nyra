struct QSPart {
    data: [i32; 8]
    pivot: i32
}

fn Quick_partition(arr: [i32; 8], lo, hi){
    let mut arr = arr
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
    return QSPart { data: arr, pivot: i + 1 }
}

fn Quick_sort_rec(arr: [i32; 8], lo, hi){
    let mut arr = arr
    if lo < hi {
        let part = Quick_partition(arr, lo, hi)
        arr = part.data
        arr = Quick_sort_rec(arr, lo, part.pivot - 1)
        arr = Quick_sort_rec(arr, part.pivot + 1, hi)
    }
    return arr
}

fn Arr_print(arr: [i32; 8], len){
    let mut i = 0
    while i < len {
        print(arr[i])
        i = i + 1
    }
}

fn QuickSort_run(){
    let mut data = [10, 7, 8, 9, 1, 5, 2, 3]
    let len = 8
    print("quick sort (recursion):")
    time_start("quick")
    data = Quick_sort_rec(data, 0, len - 1)
    time_end("quick")
    Arr_print(data, len)
}
