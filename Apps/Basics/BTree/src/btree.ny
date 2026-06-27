struct BTree {
    keys: [i32; 32]
    count: i32
    order: i32
}

fn BTree_new(order){
    return BTree {
        keys: [0; 32],
        count: 0,
        order: order,
    }
}

fn BTree_insert(mut t, key){
    if t.count >= 32 {
        return t
    }
    let mut pos = t.count
    let mut i = 0
    while i < t.count {
        if t.keys[i] > key {
            pos = i
            break
        }
        i = i + 1
    }
    let mut j = t.count
    while j > pos {
        t.keys[j] = t.keys[j - 1]
        j = j - 1
    }
    t.keys[pos] = key
    t.count = t.count + 1
    return t
}

fn BTree_print(t){
    let mut i = 0
    while i < t.count {
        print(t.keys[i])
        i = i + 1
    }
}

fn BTree_run(){
    print("B-tree node (sorted keys, order 3):")
    let mut t = BTree_new(3)
    t = BTree_insert(t, 10)
    t = BTree_insert(t, 20)
    t = BTree_insert(t, 5)
    t = BTree_insert(t, 6)
    t = BTree_insert(t, 12)
    t = BTree_insert(t, 30)
    BTree_print(t)
}
