fn Heap_sift(arr: [i32; 8], len, root){
    let mut arr = arr
    let mut largest = root
    let left = 2 * root + 1
    let right = 2 * root + 2
    if left < len && arr[left] > arr[largest] {
        largest = left
    }
    if right < len && arr[right] > arr[largest] {
        largest = right
    }
    if largest != root {
        let tmp = arr[root]
        arr[root] = arr[largest]
        arr[largest] = tmp
        arr = Heap_sift(arr, len, largest)
    }
    return arr
}

fn Heap_sort(arr: [i32; 8], len){
    let mut arr = arr
    let mut i = len / 2 - 1
    while i >= 0 {
        arr = Heap_sift(arr, len, i)
        i = i - 1
    }
    let mut end = len - 1
    while end > 0 {
        let tmp = arr[0]
        arr[0] = arr[end]
        arr[end] = tmp
        arr = Heap_sift(arr, end, 0)
        end = end - 1
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

fn HeapSort_run(){
    let mut data = [12, 11, 13, 5, 6, 7, 2, 3]
    let len = 8
    print("heap sort:")
    time_start("heap")
    data = Heap_sort(data, len)
    time_end("heap")
    Arr_print(data, len)
}
