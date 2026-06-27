import "stdlib/arc.ny"

struct GraphEdge Send {
    from_id: i32
    to_id: i32
    shared_label: Arc<string>
}

fn share_label(name: string) -> Arc<string> {
    let root = Arc_from_string(name)
    return Arc_clone_string(root)
}

fn main() {
    let shared = share_label("node-alpha")
    let edge = GraphEdge { from_id: 1, to_id: 2, shared_label: shared }
    print(Arc_get_string(edge.shared_label))
    print(edge.from_id)
    print(edge.to_id)
}
