import "stdlib/collections/btree_map.ny"

fn BTreeDatabase_run() {
    let map = BTreeMap_str_str_insert(BTreeMap_str_str_insert(BTreeMap_str_str_insert(BTreeMap_str_str_new(), "apple", "red"), "banana", "yellow"), "cherry", "dark")
    print(`apple  = ${BTreeMap_str_str_get(map, "apple")}`)
    print(`banana = ${BTreeMap_str_str_get(map, "banana")}`)
    print(`date   = ${BTreeMap_str_str_get(map, "date")}`)
    print(`min_key = ${BTreeMap_str_str_min_key(map)} max_key = ${BTreeMap_str_str_max_key(map)} len=${BTreeMap_str_str_len(map)}`)
    print("stdlib BTreeMap_str_str — sorted StrVec + binary search")
}
