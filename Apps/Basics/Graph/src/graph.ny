struct Graph {
    n: i32
    adj: [i32; 25]
}

fn Graph_new(nodes){
    return Graph {
        n: nodes,
        adj: [0; 25],
    }
}

fn Graph_idx(from, to){
    return from * 5 + to
}

fn Graph_add_edge(g, from, to, weight){
    g.adj[Graph_idx(from, to)] = weight
    g.adj[Graph_idx(to, from)] = weight
    return g
}

fn Graph_neighbors(g, node){
    print(`neighbors of ${node}`)
    let mut i = 0
    while i < g.n {
        let w = g.adj[Graph_idx(node, i)]
        if w > 0 {
            print(` -> ${i} weight ${w}`)
        }
        i = i + 1
    }
}

fn Graph_run(){
    print("weighted graph (adjacency matrix):")
    let mut g = Graph_new(5)
    g = Graph_add_edge(g, 0, 1, 2)
    g = Graph_add_edge(g, 0, 2, 4)
    g = Graph_add_edge(g, 1, 2, 1)
    g = Graph_add_edge(g, 1, 3, 7)
    g = Graph_add_edge(g, 2, 4, 3)
    Graph_neighbors(g, 1)
}
