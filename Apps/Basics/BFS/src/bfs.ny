struct Graph {
    n: i32
    adj: [i32; 25]
}

struct Queue {
    data: ptr
    head: i32
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

fn Queue_new(){
    return Queue { data: Vec_i32_new(), head: 0 }
}

fn Queue_push(q, v){
    Vec_i32_push(q.data, v)
    return q
}

fn Queue_empty(q){
    return if q.head >= Vec_i32_len(q.data) { 1 } else { 0 }
}

fn Queue_pop(q){
    q.head = q.head + 1
    return q
}

fn Queue_front(q){
    return Vec_i32_get(q.data, q.head)
}

fn BFS_run(){
    print("BFS traversal from node 0:")
    let mut g = G_new()
    g = G_add(g, 0, 1)
    g = G_add(g, 0, 2)
    g = G_add(g, 1, 3)
    g = G_add(g, 2, 4)
    let mut queue = Queue_new()
    let mut visited = [0; 5]
    queue = Queue_push(queue, 0)
    visited[0] = 1
    while Queue_empty(queue) == 0 {
        let node = Queue_front(queue)
        queue = Queue_pop(queue)
        print(node)
        let mut i = 0
        while i < g.n {
            if g.adj[G_idx(node, i)] == 1 && visited[i] == 0 {
                visited[i] = 1
                queue = Queue_push(queue, i)
            }
            i = i + 1
        }
    }
    Vec_i32_free(queue.data)
}
