// Stdlib gaps v1.24.0 — btree pages, LSM compaction, SQL parser, SSTable.

import "stdlib/db/resp.ny"
import "stdlib/db/sstable.ny"
import "stdlib/db/lsm.ny"
import "stdlib/db/sql_parse.ny"
import "stdlib/collections/btree_map.ny"
import "stdlib/collections/btree_pages.ny"

fn test_resp_ping() {
    let wire = "*1\r\n$4\r\nPING\r\n"
    let args = Resp_decode_array(wire, 0)
    if args.len() != 1 {
        return 0
    }
    if strcmp(Resp_cmd_name(args), "PING") != 0 {
        return 0
    }
    return 1
}

fn test_btree_order() {
    let map = BTreeMap_str_str_insert(BTreeMap_str_str_insert(BTreeMap_str_str_new(), "z", "last"), "a", "first")
    if strcmp(BTreeMap_str_str_min_key(map), "a") != 0 {
        return 0
    }
    if strcmp(BTreeMap_str_str_max_key(map), "z") != 0 {
        return 0
    }
    if BTreeMap_str_str_len(map) != 2 {
        return 0
    }
    return 1
}

fn test_btree_paged_descent() {
    let mut tree = BTreePaged_new()
    tree = BTreePaged_insert(tree, "a", "1")
    tree = BTreePaged_insert(tree, "b", "2")
    tree = BTreePaged_insert(tree, "c", "3")
    tree = BTreePaged_insert(tree, "d", "4")
    tree = BTreePaged_insert(tree, "e", "5")
    tree = BTreePaged_insert(tree, "f", "6")
    tree = BTreePaged_insert(tree, "g", "7")
    tree = BTreePaged_insert(tree, "h", "8")
    tree = BTreePaged_insert(tree, "i", "9")
    if strcmp(BTreePaged_get(tree, "a"), "1") != 0 {
        return 0
    }
    if strcmp(BTreePaged_get(tree, "e"), "5") != 0 {
        return 0
    }
    if strcmp(BTreePaged_get(tree, "i"), "9") != 0 {
        return 0
    }
    if BTreePaged_node_count(tree) < 3 {
        return 0
    }
    return 1
}

fn test_sstable_roundtrip() {
    let path = "sst_test_tmp.sst"
    let mut keys = StrVec_new()
    keys = keys.push("alpha")
    keys = keys.push("beta")
    let mut vals = StrVec_new()
    vals = vals.push("1")
    vals = vals.push("2")
    let table = SsTable_new(path)
    if SsTable_write_sorted(table, keys, vals) != 0 {
        return 0
    }
    if strcmp(SsTable_get(table, "beta"), "2") != 0 {
        return 0
    }
    remove_file(path)
    return 1
}

fn test_lsm_flush() {
    let dir = "lsm_flush_tmp"
    let mut tree = LsmTree_new(dir)
    tree = LsmTree_put(tree, "k1", "v1")
    tree = LsmTree_put(tree, "k2", "v2")
    tree = LsmTree_put(tree, "k3", "v3")
    tree = LsmTree_put(tree, "k4", "v4")
    tree = LsmTree_put(tree, "k5", "v5")
    tree = LsmTree_put(tree, "k6", "v6")
    tree = LsmTree_put(tree, "k7", "v7")
    tree = LsmTree_put(tree, "k8", "v8")
    let hit1 = LsmTree_lookup(tree, "k1")
    tree = hit1.tree
    if strcmp(hit1.value, "v1") != 0 {
        return 0
    }
    let hit8 = LsmTree_lookup(tree, "k8")
    if strcmp(hit8.value, "v8") != 0 {
        return 0
    }
    remove_file(strcat(dir, "/lsm.wal"))
    return 1
}

fn test_lsm_compaction() {
    let dir = "lsm_test_tmp"
    let mut tree = LsmTree_new(dir)
    tree = LsmTree_put(tree, "k1", "v1")
    tree = LsmTree_put(tree, "k2", "v2")
    tree = LsmTree_put(tree, "k3", "v3")
    tree = LsmTree_put(tree, "k4", "v4")
    let hit1 = LsmTree_lookup(tree, "k1")
    tree = hit1.tree
    if strcmp(hit1.value, "v1") != 0 {
        return 0
    }
    let hit4 = LsmTree_lookup(tree, "k4")
    tree = hit4.tree
    if strcmp(hit4.value, "v4") != 0 {
        return 0
    }
    tree = LsmTree_delete(tree, "k3")
    let hit3 = LsmTree_lookup(tree, "k3")
    if strlen(hit3.value) != 0 {
        return 0
    }
    remove_file(strcat(dir, "/lsm.wal"))
    return 1
}

fn test_sql_parse() {
    let sel = SqlParse_parse("SELECT name FROM users WHERE id = 1")
    if strcmp(sel.kind, "select") != 0 {
        return 0
    }
    if strcmp(sel.where_col, "id") != 0 {
        return 0
    }
    if strcmp(sel.where_op, "=") != 0 {
        return 0
    }
    let ins = SqlParse_parse("INSERT INTO t (a) VALUES (1)")
    if strcmp(ins.kind, "insert") != 0 {
        return 0
    }
    if ins.values.len() != 1 {
        return 0
    }
    let upd = SqlParse_parse("UPDATE users SET name = 'nyra' WHERE id = 1")
    if strcmp(upd.kind, "update") != 0 {
        return 0
    }
    if strcmp(upd.set_col, "name") != 0 {
        return 0
    }
    let del = SqlParse_parse("DELETE FROM users WHERE id = 1")
    if strcmp(del.kind, "delete") != 0 {
        return 0
    }
    if strcmp(del.table, "users") != 0 {
        return 0
    }
    return 1
}

fn test_btree_range() {
    let mut tree = BTreePaged_new()
    tree = BTreePaged_insert(tree, "a", "1")
    tree = BTreePaged_insert(tree, "c", "3")
    tree = BTreePaged_insert(tree, "e", "5")
    tree = BTreePaged_insert(tree, "g", "7")
    tree = BTreePaged_insert(tree, "i", "9")
    let range = BTreePaged_range(tree, "b", "h")
    if range.keys.len() != 3 {
        return 0
    }
    if strcmp(range.keys.get(0), "c") != 0 {
        return 0
    }
    if strcmp(range.values.get(2), "7") != 0 {
        return 0
    }
    let all = BTreePaged_keys(tree)
    if all.len() != 5 {
        return 0
    }
    return 1
}

fn main() {
    if test_resp_ping() == 0 {
        print("FAIL resp")
        return
    }
    if test_btree_order() == 0 {
        print("FAIL btree")
        return
    }
    if test_btree_paged_descent() == 0 {
        print("FAIL btree_paged")
        return
    }
    if test_sstable_roundtrip() == 0 {
        print("FAIL sstable")
        return
    }
    if test_lsm_compaction() == 0 {
        print("FAIL lsm")
        return
    }
    if test_lsm_flush() == 0 {
        print("FAIL lsm_flush")
        return
    }
    if test_sql_parse() == 0 {
        print("FAIL sql_parse")
        return
    }
    if test_btree_range() == 0 {
        print("FAIL btree_range")
        return
    }
    print("stdlib_gaps ok")
}
