fn main() {
    let map = BTreeMap_str_str_insert(BTreeMap_str_str_insert(BTreeMap_str_str_new(), "b", "two"), "a", "one")
    print(BTreeMap_str_str_min_key(map))
    print(BTreeMap_str_str_get(map, "a"))
    print(BTreeMap_str_str_len(map))
}
