// B-tree range scan — ordered keys between bounds.

import "stdlib/collections/btree_pages.ny"

fn main() {
    let mut m = BTreePaged_new()
    m = BTreePaged_insert(m, "a", "1")
    m = BTreePaged_insert(m, "c", "3")
    m = BTreePaged_insert(m, "e", "5")
    m = BTreePaged_insert(m, "g", "7")
    m = BTreePaged_insert(m, "i", "9")
    let range = BTreePaged_range(m, "b", "h")
    print(range.keys.len())
    print(range.keys.get(0))
    print(range.values.get(2))
    print(BTreePaged_keys(m).len())
}
