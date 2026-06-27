enum RBColor {
    Red
    Black
}

struct RedBlackTree {
    keys: [i32; 16]
    colors: [i32; 16]
    left: [i32; 16]
    right: [i32; 16]
    size: i32
}

fn RB_new(){
    return RedBlackTree {
        keys: [0; 16],
        colors: [0; 16],
        left: [-1; 16],
        right: [-1; 16],
        size: 0,
    }
}

fn RB_insert(mut t, key){
    let id = t.size
    t.keys[id] = key
    t.colors[id] = 0
    t.left[id] = -1
    t.right[id] = -1
    t.size = t.size + 1
    if id > 0 {
        t.colors[id - 1] = 1
    }
    return t
}

fn RB_inorder(t, id){
    if id < 0 || id >= t.size {
        return
    }
    RB_inorder(t, t.left[id])
    let color = if t.colors[id] == 0 { "R" } else { "B" }
    print(`${t.keys[id]}(${color})`)
    RB_inorder(t, t.right[id])
}

fn RedBlackTree_run(){
    print("red-black tree (enum colors):")
    let mut t = RB_new()
    t = RB_insert(t, 10)
    t = RB_insert(t, 20)
    t = RB_insert(t, 5)
    t = RB_insert(t, 15)
    print("inorder (key+color):")
    RB_inorder(t, 0)
}
