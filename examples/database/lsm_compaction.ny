// LSM leveled compaction — memtable flush, L0 merge, tombstones.

import "stdlib/db/lsm.ny"

fn main() {
    let dir = "lsm_example_data"
    let mut tree = LsmTree_new(dir)
    tree = LsmTree_put(tree, "user:1", "alice")
    tree = LsmTree_put(tree, "user:2", "bob")
    tree = LsmTree_put(tree, "user:3", "carol")
    tree = LsmTree_put(tree, "user:4", "dave")
    tree = LsmTree_put(tree, "user:5", "erin")
    tree = LsmTree_put(tree, "user:6", "frank")
    tree = LsmTree_put(tree, "user:7", "grace")
    tree = LsmTree_put(tree, "user:8", "henry")
    tree = LsmTree_delete(tree, "user:3")
    let hit1 = LsmTree_lookup(tree, "user:1")
    tree = hit1.tree
    print(hit1.value)
    let hit3 = LsmTree_lookup(tree, "user:3")
    tree = hit3.tree
    print(hit3.value)
    let hit8 = LsmTree_lookup(tree, "user:8")
    print(hit8.value)
}
