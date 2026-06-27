fn BinarySearch_find(data: [i32; 7], len, target){
    let mut lo = 0
    let mut hi = len - 1
    while lo <= hi {
        let mid = (lo + hi) / 2
        let v = data[mid]
        if v == target {
            return mid
        }
        if v < target {
            lo = mid + 1
        } else {
            hi = mid - 1
        }
    }
    return -1
}

fn BinarySearch_run(){
    let data = [2, 5, 8, 12, 16, 23, 38]
    let len = data.len()
    print("binary search on sorted array:")
    print(`search 8 -> index ${BinarySearch_find(data, len, 8)}`)
    print(`search 16 -> index ${BinarySearch_find(data, len, 16)}`)
    print(`search 1 -> index ${BinarySearch_find(data, len, 1)}`)
    print(`search 38 -> index ${BinarySearch_find(data, len, 38)}`)
}
