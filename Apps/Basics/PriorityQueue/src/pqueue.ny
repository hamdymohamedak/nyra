struct PriorityQueue {
    heap: [i32; 16]
    len: i32
}

fn PQueue_new(){
    return PriorityQueue {
        heap: [0; 16],
        len: 0,
    }
}

fn PQueue_swap(mut q, i, j){
    let tmp = q.heap[i]
    q.heap[i] = q.heap[j]
    q.heap[j] = tmp
    return q
}

fn PQueue_sift_up(mut q, i){
    let mut idx = i
    while idx > 0 {
        let parent = (idx - 1) / 2
        if q.heap[parent] <= q.heap[idx] {
            idx = 0
        } else {
            q = PQueue_swap(q, parent, idx)
            idx = parent
        }
    }
    return q
}

fn PQueue_push(mut q, value){
    if q.len >= 16 {
        return q
    }
    q.heap[q.len] = value
    q.len = q.len + 1
    q = PQueue_sift_up(q, q.len - 1)
    return q
}

fn PQueue_sift_down(mut q, i){
    let mut idx = i
    let mut done = 0
    while done == 0 {
        let left = 2 * idx + 1
        let right = 2 * idx + 2
        let mut smallest = idx
        if left < q.len && q.heap[left] < q.heap[smallest] {
            smallest = left
        }
        if right < q.len && q.heap[right] < q.heap[smallest] {
            smallest = right
        }
        if smallest == idx {
            done = 1
        } else {
            q = PQueue_swap(q, idx, smallest)
            idx = smallest
        }
    }
    return q
}

fn PQueue_pop(mut q){
    if q.len == 0 {
        return q
    }
    print(q.heap[0])
    q.len = q.len - 1
    if q.len > 0 {
        q.heap[0] = q.heap[q.len]
        q = PQueue_sift_down(q, 0)
    }
    return q
}

fn PriorityQueue_run(){
    print("min priority queue (binary heap):")
    let mut q = PQueue_new()
    q = PQueue_push(q, 5)
    q = PQueue_push(q, 3)
    q = PQueue_push(q, 8)
    q = PQueue_push(q, 1)
    q = PQueue_pop(q)
    q = PQueue_pop(q)
    q = PQueue_pop(q)
    q = PQueue_pop(q)
}
