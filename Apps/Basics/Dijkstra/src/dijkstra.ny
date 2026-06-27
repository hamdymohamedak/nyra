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

fn G_set(g, a, b, w){
    g.adj[G_idx(a, b)] = w
    return g
}

fn Dijkstra_min_dist(dist: [i32; 5], done: [i32; 5], n){
    let mut best = -1
    let mut i = 0
    while i < n {
        if done[i] == 0 {
            if best < 0 || dist[i] < dist[best] {
                best = i
            }
        }
        i = i + 1
    }
    return best
}

fn Dijkstra_run(){
    print("Dijkstra shortest paths from 0:")
    let mut g = G_new()
    g = G_set(g, 0, 1, 2)
    g = G_set(g, 0, 2, 4)
    g = G_set(g, 1, 2, 1)
    g = G_set(g, 1, 3, 7)
    g = G_set(g, 2, 4, 3)
    let mut dist = [999, 999, 999, 999, 999]
    let mut done = [0; 5]
    dist[0] = 0
    let mut step = 0
    while step < g.n {
        let u = Dijkstra_min_dist(dist, done, g.n)
        if u < 0 {
            step = g.n
        } else {
            done[u] = 1
            let mut v = 0
            while v < g.n {
                let w = g.adj[G_idx(u, v)]
                if w > 0 {
                    let alt = dist[u] + w
                    if alt < dist[v] {
                        dist[v] = alt
                    }
                }
                v = v + 1
            }
            step = step + 1
        }
    }
    let mut i = 0
    while i < g.n {
        print(`dist[${i}] = ${dist[i]}`)
        i = i + 1
    }
}
