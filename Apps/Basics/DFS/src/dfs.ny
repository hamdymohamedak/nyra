struct Graph {
    n: i32
    adj: [i32; 25]
}

fn G_idx(from, to){
    return from * 5 + to
}

fn G_new(){
    return Graph {
        n: 5,
        adj: [0; 25],
    }
}

fn G_add(g, a, b){
    g.adj[G_idx(a, b)] = 1
    g.adj[G_idx(b, a)] = 1
    return g
}

fn DFS_run(){
    print("DFS traversal (iterative stack) from node 0:")
    let mut g = G_new()
    g = G_add(g, 0, 1)
    g = G_add(g, 0, 2)
    g = G_add(g, 1, 3)
    g = G_add(g, 2, 4)
    let mut stack = Vec_i32_new()
    let mut visited = [0; 5]
    Vec_i32_push(stack, 0)
    while Vec_i32_len(stack) > 0 {
        let node = Vec_i32_pop(stack)
        if visited[node] == 0 {
            visited[node] = 1
            print(node)
            let mut i = g.n - 1
            while i >= 0 {
                if g.adj[G_idx(node, i)] == 1 && visited[i] == 0 {
                    Vec_i32_push(stack, i)
                }
                i = i - 1
            }
        }
    }
    Vec_i32_free(stack)
}
