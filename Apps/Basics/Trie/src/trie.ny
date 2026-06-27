struct Trie {
    edges: ptr
    terminal: ptr
    nodes: i32
}

fn Trie_slot(node, ci){
    return node * 26 + ci
}

fn Trie_new(){
    let edges = Vec_i32_new()
    let terminal = Vec_i32_new()
    let mut i = 0
    while i < 26 {
        Vec_i32_push(edges, -1)
        i = i + 1
    }
    Vec_i32_push(terminal, 0)
    return Trie { edges: edges, terminal: terminal, nodes: 1 }
}

fn Trie_child_index(c){
    if c >= 97 && c <= 122 {
        return c - 97
    }
    if c >= 65 && c <= 90 {
        return c - 65
    }
    return -1
}

fn Trie_grow(t){
    let mut i = 0
    while i < 26 {
        Vec_i32_push(t.edges, -1)
        i = i + 1
    }
    Vec_i32_push(t.terminal, 0)
    t.nodes = t.nodes + 1
    return t
}

fn Trie_get_child(t, node, ci){
    return Vec_i32_get(t.edges, Trie_slot(node, ci))
}

fn Trie_insert(t, word){
    let len = strlen(word)
    let mut node = 0
    let mut i = 0
    while i < len {
        let ci = Trie_child_index(char_at(word, i))
        if ci >= 0 {
            let slot = Trie_slot(node, ci)
            while Vec_i32_len(t.edges) <= slot {
                let mut j = 0
                while j < 26 {
                    Vec_i32_push(t.edges, -1)
                    j = j + 1
                }
                Vec_i32_push(t.terminal, 0)
                t.nodes = t.nodes + 1
            }
            let next = Vec_i32_get(t.edges, slot)
            if next < 0 {
                let new_node = t.nodes
                t.nodes = t.nodes + 1
                let mut j = 0
                while j < 26 {
                    Vec_i32_push(t.edges, -1)
                    j = j + 1
                }
                Vec_i32_push(t.terminal, 0)
                Vec_i32_push(t.edges, 0)
                node = new_node
            } else {
                node = next
            }
        }
        i = i + 1
    }
    return t
}

fn Trie_contains(t, word){
    let len = strlen(word)
    let mut node = 0
    let mut i = 0
    while i < len {
        let ci = Trie_child_index(char_at(word, i))
        if ci < 0 {
            return 0
        }
        let slot = Trie_slot(node, ci)
        if slot >= Vec_i32_len(t.edges) {
            return 0
        }
        let next = Vec_i32_get(t.edges, slot)
        if next < 0 {
            return 0
        }
        node = next
        i = i + 1
    }
    return 1
}

fn Trie_run(){
    print("trie prefix tree:")
    let mut t = Trie_new()
    t = Trie_insert(t, "cat")
    t = Trie_insert(t, "car")
    t = Trie_insert(t, "card")
    print(`contains cat: ${Trie_contains(t, "cat")}`)
    print(`contains car: ${Trie_contains(t, "car")}`)
    print(`contains card: ${Trie_contains(t, "card")}`)
    print(`contains dog: ${Trie_contains(t, "dog")}`)
}
