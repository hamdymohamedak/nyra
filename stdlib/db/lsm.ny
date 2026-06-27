// LSM-tree — memtable, WAL, leveled SST compaction, tombstones.

import "sstable.ny"

const LSM_TOMBSTONE = "\x00__TOMBSTONE__"
const LSM_FLUSH_AT = 8
const LSM_COMPACT_AT = 2

struct LsmTree {
    dir: string
    memtable: HashMap_str_str
    sorted_keys: StrVec
    l0_count: i32
    l1_path: string
    wal_path: string
    seq: i32
}

fn LsmTree_join(root: string, suffix: string) -> string {
    return strcat(clone root, suffix)
}

fn LsmTree_paths(dir: string) -> StrVec {
    let root = clone dir
    let mut out = StrVec_new()
    out = out.push(LsmTree_join(root, "/lsm.wal"))
    out = out.push(LsmTree_join(root, "/lsm.manifest"))
    out = out.push(LsmTree_join(root, "/lsm.l1.sst"))
    return out
}

fn LsmTree_new(dir: string) -> LsmTree {
    let stored = clone dir
    create_dir(clone stored)
    let paths = LsmTree_paths(clone stored)
    return LsmTree {
        dir: stored,
        memtable: HashMap_str_str_new(),
        sorted_keys: StrVec_new(),
        l0_count: 0,
        l1_path: clone paths.get(2),
        wal_path: clone paths.get(0),
        seq: 0
    }
}

fn LsmTree_vec_get(vec: StrVec, index: i32) -> string {
    return clone vec.get(index)
}

fn LsmTree_sorted_insert(keys: StrVec, key: string) -> StrVec {
    let n = keys.len()
    let mut lo = 0
    let mut hi = n
    while lo < hi {
        let mid = (lo + hi) / 2
        let cmp = strcmp(LsmTree_vec_get(keys, mid), key)
        if cmp == 0 {
            return keys
        }
        if cmp < 0 {
            lo = mid + 1
        } else {
            hi = mid
        }
    }
    let mut out = StrVec_new()
    let mut i = 0
    while i < n {
        if i == lo {
            out = out.push(key)
        }
        out = out.push(LsmTree_vec_get(keys, i))
        i = i + 1
    }
    if lo == n {
        out = out.push(key)
    }
    return out
}

fn LsmTree_wal_append(wal_path: string, key: string, value: string) -> void {
    let line = strcat(key, strcat("\t", value))
    append_file(clone wal_path, strcat(line, "\n"))
    fsync_file(clone wal_path)
}

fn LsmTree_clear_wal(tree: LsmTree) -> LsmTree {
    let wal_path = clone tree.wal_path
    write_file(clone wal_path, "")
    fsync_file(clone wal_path)
    return tree
}

fn LsmTree_l0_path_dir(dir: string, id: i32) -> string {
    return LsmTree_join(dir, strcat("/lsm.l0.", strcat(i32_to_string(id), ".sst")))
}

fn LsmTree_l0_path(dir: string, id: i32) -> string {
    return LsmTree_l0_path_dir(clone dir, id)
}

fn LsmTree_flush(tree: LsmTree) -> LsmTree {
    let dir = clone tree.dir
    let l1_path = clone tree.l1_path
    let wal_path = clone tree.wal_path
    let l0_count = tree.l0_count
    let file_id = tree.seq
    let keys = tree.sorted_keys
    let mem = tree.memtable
    let mut values = StrVec_new()
    let n = keys.len()
    let mut i = 0
    while i < n {
        let row_key = LsmTree_vec_get(keys, i)
        values = values.push(clone mem.get(row_key))
        i = i + 1
    }
    let out_path = LsmTree_l0_path_dir(clone dir, file_id)
    SsTable_write_sorted(SsTable_new(clone out_path), keys, values)
    fsync_file(clone out_path)
    write_file(clone wal_path, "")
    fsync_file(clone wal_path)
    let cleared = LsmTree {
        dir: clone dir,
        memtable: HashMap_str_str_new(),
        sorted_keys: StrVec_new(),
        l0_count: l0_count + 1,
        l1_path: clone l1_path,
        wal_path: clone wal_path,
        seq: file_id + 1
    }
    if cleared.l0_count >= LSM_COMPACT_AT {
        return LsmTree_compact_l0(cleared)
    }
    let out = cleared
    return out
}

fn LsmTree_compact_l0(tree: LsmTree) -> LsmTree {
    if tree.l0_count < LSM_COMPACT_AT {
        let out = tree
        return out
    }
    let dir = clone tree.dir
    let l1_path = clone tree.l1_path
    let wal_path = clone tree.wal_path
    let l0_count = tree.l0_count
    let seq = tree.seq
    let mem = tree.memtable
    let keys = tree.sorted_keys
    let newest = LsmTree_l0_path_dir(clone dir, seq - 1)
    let older = LsmTree_l0_path_dir(clone dir, seq - 2)
    let compact0 = LsmTree_join(clone dir, "/lsm.compact.0.sst")
    sstable_merge_files(clone compact0, clone older, clone newest)
    let l1 = LsmTree_join(clone dir, "/lsm.l1.sst")
    if exists(clone l1) == 1 {
        let compact1 = LsmTree_join(clone dir, "/lsm.compact.1.sst")
        sstable_merge_files(clone compact1, clone l1, clone compact0)
        remove_file(clone compact0)
        remove_file(clone l1)
        write_file(clone l1, read_file(clone compact1))
        remove_file(clone compact1)
    } else {
        write_file(clone l1, read_file(clone compact0))
        remove_file(clone compact0)
    }
    fsync_file(clone l1)
    remove_file(clone newest)
    remove_file(clone older)
    let merged = LsmTree {
        dir: clone dir,
        memtable: mem,
        sorted_keys: keys,
        l0_count: l0_count - 2,
        l1_path: clone l1_path,
        wal_path: clone wal_path,
        seq: seq - 2
    }
    let out = merged
    return out
}

fn LsmTree_put_mem(tree: LsmTree, key: string, value: string) -> LsmTree {
    let dir = clone tree.dir
    let l1_path = clone tree.l1_path
    let wal_path = clone tree.wal_path
    let l0_count = tree.l0_count
    let seq = tree.seq
    let mem = tree.memtable.insert(key, value)
    let keys = LsmTree_sorted_insert(tree.sorted_keys, key)
    return LsmTree {
        dir: dir,
        memtable: mem,
        sorted_keys: keys,
        l0_count: l0_count,
        l1_path: l1_path,
        wal_path: wal_path,
        seq: seq
    }
}

fn LsmTree_put(tree: LsmTree, key: string, value: string) -> LsmTree {
    LsmTree_wal_append(clone tree.wal_path, key, value)
    let next = LsmTree_put_mem(tree, key, value)
    if next.sorted_keys.len() >= LSM_FLUSH_AT {
        return LsmTree_flush(next)
    }
    return next
}

fn LsmTree_delete(tree: LsmTree, key: string) -> LsmTree {
    return LsmTree_put(tree, key, LSM_TOMBSTONE)
}

fn LsmTree_get_from_sst(path: string, key: string) -> string {
    if exists(clone path) == 0 {
        return ""
    }
    return SsTable_get(SsTable_new(clone path), key)
}

struct LsmLookup {
    tree: LsmTree
    value: string
}

fn LsmTree_rebuild(dir: string, mem: HashMap_str_str, keys: StrVec, l0_count: i32, l1_path: string, wal_path: string, seq: i32) -> LsmTree {
    return LsmTree {
        dir: dir,
        memtable: mem,
        sorted_keys: keys,
        l0_count: l0_count,
        l1_path: l1_path,
        wal_path: wal_path,
        seq: seq
    }
}

fn LsmTree_lookup(tree: LsmTree, key: string) -> LsmLookup {
    let dir = clone tree.dir
    let l1_path = clone tree.l1_path
    let wal_path = clone tree.wal_path
    let l0_count = tree.l0_count
    let seq = tree.seq
    let mem = tree.memtable
    let keys = tree.sorted_keys
    let mut value = ""
    if mem.contains(key) == 1 {
        value = clone mem.get(key)
        if strcmp(value, LSM_TOMBSTONE) == 0 {
            value = ""
        }
    } else {
        let mut i = seq - 1
        let mut found = 0
        while i >= 0 && found == 0 {
            let hit = LsmTree_get_from_sst(LsmTree_l0_path_dir(clone dir, i), key)
            if strlen(hit) > 0 {
                if strcmp(hit, LSM_TOMBSTONE) == 0 {
                    value = ""
                } else {
                    value = hit
                }
                found = 1
            }
            i = i - 1
        }
        if strlen(value) == 0 {
            let l1_hit = LsmTree_get_from_sst(clone l1_path, key)
            if strlen(l1_hit) > 0 && strcmp(l1_hit, LSM_TOMBSTONE) != 0 {
                value = l1_hit
            }
        }
    }
    return LsmLookup {
        tree: LsmTree_rebuild(dir, mem, keys, l0_count, l1_path, wal_path, seq),
        value: value
    }
}

fn LsmTree_get(tree: LsmTree, key: string) -> string {
    return LsmTree_lookup(tree, key).value
}

fn LsmTree_replay_line(tree: LsmTree, line: string) -> LsmTree {
    let pos = strstr_pos(line, "\t")
    if pos < 0 {
        return tree
    }
    let key = substring(line, 0, pos)
    let line_len = strlen(line)
    let value = substring(line, pos + 1, line_len - pos - 1)
    return LsmTree_put_mem(tree, key, value)
}

fn LsmTree_recover(dir: string) -> LsmTree {
    let tree = LsmTree_new(dir)
    if exists(clone tree.wal_path) == 0 {
        return tree
    }
    let text = read_file(clone tree.wal_path)
    let lines = StrVec_from_lines(text)
    let mut out = tree
    let n = lines.len()
    let mut i = 0
    while i < n {
        out = LsmTree_replay_line(out, LsmTree_vec_get(lines, i))
        i = i + 1
    }
    return out
}
