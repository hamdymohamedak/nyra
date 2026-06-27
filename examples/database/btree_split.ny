// B-tree page split with internal descent — multi-level lookup.

import "stdlib/collections/btree_pages.ny"

fn main() {
    let mut m = BTreePaged_new()
    m = BTreePaged_insert(m, "a", "1")
    m = BTreePaged_insert(m, "b", "2")
    m = BTreePaged_insert(m, "c", "3")
    m = BTreePaged_insert(m, "d", "4")
    m = BTreePaged_insert(m, "e", "5")
    m = BTreePaged_insert(m, "f", "6")
    m = BTreePaged_insert(m, "g", "7")
    m = BTreePaged_insert(m, "h", "8")
    m = BTreePaged_insert(m, "i", "9")
    print(BTreePaged_node_count(m))
    print(BTreePaged_get(m, "b"))
    print(BTreePaged_get(m, "h"))
}
