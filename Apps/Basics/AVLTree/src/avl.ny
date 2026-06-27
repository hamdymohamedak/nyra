struct AVLTree {
    keys: [i32; 16]
    left: [i32; 16]
    right: [i32; 16]
    height: [i32; 16]
    size: i32
}

fn AVL_new(){
    return AVLTree {
        keys: [0; 16],
        left: [-1; 16],
        right: [-1; 16],
        height: [0; 16],
        size: 0,
    }
}

fn AVL_height(t, id){
    if id < 0 {
        return 0
    }
    return t.height[id]
}

fn AVL_max(a, b){
    if a > b {
        return a
    }
    return b
}

fn AVL_update_height(mut t, id){
    t.height[id] = AVL_max(AVL_height(t, t.left[id]), AVL_height(t, t.right[id])) + 1
    return t
}

fn AVL_rotate_right(mut t, y){
    let x = t.left[y]
    let sub = t.right[x]
    t.right[x] = y
    t.left[y] = sub
    t = AVL_update_height(t, y)
    t = AVL_update_height(t, x)
    return t
}

fn AVL_rotate_left(mut t, x){
    let y = t.right[x]
    let sub = t.left[y]
    t.left[y] = x
    t.right[x] = sub
    t = AVL_update_height(t, x)
    t = AVL_update_height(t, y)
    return t
}

fn AVL_balance(mut t, id){
    t = AVL_update_height(t, id)
    let bf = AVL_height(t, t.left[id]) - AVL_height(t, t.right[id])
    if bf > 1 {
        if AVL_height(t, t.left[t.left[id]]) < AVL_height(t, t.right[t.left[id]]) {
            t = AVL_rotate_left(t, t.left[id])
        }
        t = AVL_rotate_right(t, id)
    } else {
        if bf < -1 {
            if AVL_height(t, t.right[t.right[id]]) > AVL_height(t, t.left[t.right[id]]) {
                t = AVL_rotate_right(t, t.right[id])
            }
            t = AVL_rotate_left(t, id)
        }
    }
    return t
}

fn AVL_insert_rec(mut t, id, key){
    if id < 0 {
        let nid = t.size
        t.keys[nid] = key
        t.left[nid] = -1
        t.right[nid] = -1
        t.height[nid] = 1
        t.size = t.size + 1
        return t
    }
    if key < t.keys[id] {
        t.left[id] = t.size
        t = AVL_insert_rec(t, t.left[id], key)
    } else {
        if key > t.keys[id] {
            t.right[id] = t.size
            t = AVL_insert_rec(t, t.right[id], key)
        }
    }
    t = AVL_balance(t, id)
    return t
}

fn AVL_inorder(t, id){
    if id < 0 || id >= t.size {
        return
    }
    AVL_inorder(t, t.left[id])
    print(t.keys[id])
    AVL_inorder(t, t.right[id])
}

fn AVLTree_run(){
    print("AVL tree (rotations + recursion):")
    let mut t = AVL_new()
    t.keys[0] = 30
    t.size = 1
    t.height[0] = 1
    t = AVL_insert_rec(t, 0, 20)
    t = AVL_insert_rec(t, 0, 40)
    t = AVL_insert_rec(t, 0, 10)
    t = AVL_insert_rec(t, 0, 25)
    print("inorder:")
    AVL_inorder(t, 0)
}
