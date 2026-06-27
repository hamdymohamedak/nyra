import "stdlib/db/lsm.ny"

fn LsmTree_run() {
    let dir = "lsm_data"
    let mut tree = LsmTree_recover(dir)
    tree = LsmTree_put(tree, "page:1", "hello")
    tree = LsmTree_put(tree, "page:2", "world")
    tree = LsmTree_put(tree, "page:3", "nyra")
    tree = LsmTree_put(tree, "page:4", "lsm")
    tree = LsmTree_put(tree, "page:5", "compact")
    tree = LsmTree_put(tree, "page:6", "ready")
    tree = LsmTree_put(tree, "page:7", "prod")
    tree = LsmTree_put(tree, "page:8", "v1")
    let hit1 = LsmTree_lookup(tree, "page:1")
    tree = hit1.tree
    print(`page:1 = ${hit1.value}`)
    let hit4 = LsmTree_lookup(tree, "page:4")
    tree = hit4.tree
    print(`page:4 = ${hit4.value}`)
    let hit8 = LsmTree_lookup(tree, "page:8")
    print(`page:8 = ${hit8.value}`)
    print(`L0 count: ${hit8.tree.l0_count}`)
    print(`WAL ${hit8.tree.wal_path} + leveled compaction`)
}
