// Sorted key map — default `BTreeMap_str_str` uses flat sorted StrVec (fast for small maps).
// For page splits + multi-level nodes import `stdlib/collections/btree_pages.ny`.

struct BTreeMap_str_str {
    keys: StrVec
    values: StrVec
}

fn BTreeMap_str_str_new() -> BTreeMap_str_str {
    return BTreeMap_str_str { keys: StrVec_new(), values: StrVec_new() }
}

fn BTreeMap_str_str_find(keys: StrVec, key: string) -> i32 {
    let n = keys.len()
    let mut lo = 0
    let mut hi = n
    while lo < hi {
        let mid = (lo + hi) / 2
        let cmp = strcmp(keys.get(mid), key)
        if cmp == 0 {
            return mid
        }
        if cmp < 0 {
            lo = mid + 1
        } else {
            hi = mid
        }
    }
    return -lo - 1
}

fn StrVec_insert_at(vec: StrVec, at: i32, value: string) -> StrVec {
    let mut out = StrVec_new()
    let n = vec.len()
    let mut i = 0
    while i < n {
        if i == at {
            out = out.push(value)
        }
        out = out.push(vec.get(i))
        i = i + 1
    }
    if at == n {
        out = out.push(value)
    }
    return out
}

fn StrVec_set_at(vec: StrVec, idx: i32, value: string) -> StrVec {
    let mut out = StrVec_new()
    let n = vec.len()
    let mut i = 0
    while i < n {
        if i == idx {
            out = out.push(value)
        } else {
            out = out.push(vec.get(i))
        }
        i = i + 1
    }
    return out
}

fn BTreeMap_str_str_insert(map: BTreeMap_str_str, key: string, value: string) -> BTreeMap_str_str {
    let idx = BTreeMap_str_str_find(map.keys, key)
    if idx >= 0 {
        let vals = StrVec_set_at(map.values, idx, value)
        return BTreeMap_str_str { keys: map.keys, values: vals }
    }
    let at = -idx - 1
    let keys = StrVec_insert_at(map.keys, at, key)
    let vals = StrVec_insert_at(map.values, at, value)
    return BTreeMap_str_str { keys: keys, values: vals }
}

fn BTreeMap_str_str_get(map: BTreeMap_str_str, key: string) -> string {
    let idx = BTreeMap_str_str_find(map.keys, key)
    if idx < 0 {
        return ""
    }
    return map.values.get(idx)
}

fn BTreeMap_str_str_contains(map: BTreeMap_str_str, key: string) -> i32 {
    let idx = BTreeMap_str_str_find(map.keys, key)
    if idx < 0 {
        return 0
    }
    return 1
}

fn BTreeMap_str_str_len(map: BTreeMap_str_str) -> i32 {
    return map.keys.len()
}

fn BTreeMap_str_str_min_key(map: BTreeMap_str_str) -> string {
    if map.keys.len() == 0 {
        return ""
    }
    return map.keys.get(0)
}

fn BTreeMap_str_str_max_key(map: BTreeMap_str_str) -> string {
    let n = map.keys.len()
    if n == 0 {
        return ""
    }
    return map.keys.get(n - 1)
}

struct BTreeMap_str_i32 {
    keys: StrVec
    values: ptr
}

fn BTreeMap_str_i32_new() -> BTreeMap_str_i32 {
    return BTreeMap_str_i32 { keys: StrVec_new(), values: Vec_i32_new() }
}

fn Vec_i32_rebuild_insert(v: ptr, at: i32, value: i32) -> ptr {
    let n = vec_len(v)
    let mut out = Vec_i32_new()
    let mut i = 0
    while i < n {
        if i == at {
            vec_push(out, value)
        }
        vec_push(out, vec_get(v, i))
        i = i + 1
    }
    if at == n {
        vec_push(out, value)
    }
    Vec_i32_free(v)
    return out
}

fn Vec_i32_rebuild_set(v: ptr, idx: i32, value: i32) -> ptr {
    let n = vec_len(v)
    let mut out = Vec_i32_new()
    let mut i = 0
    while i < n {
        if i == idx {
            vec_push(out, value)
        } else {
            vec_push(out, vec_get(v, i))
        }
        i = i + 1
    }
    Vec_i32_free(v)
    return out
}

impl BTreeMap_str_i32 {
    fn insert(self, key: string, value: i32) -> BTreeMap_str_i32 {
        let idx = BTreeMap_str_str_find(self.keys, key)
        if idx >= 0 {
            let items = Vec_i32_rebuild_set(self.values, idx, value)
            return BTreeMap_str_i32 { keys: self.keys, values: items }
        }
        let at = -idx - 1
        let keys = StrVec_insert_at(self.keys, at, key)
        let items = Vec_i32_rebuild_insert(self.values, at, value)
        return BTreeMap_str_i32 { keys: keys, values: items }
    }

    fn get(self, key: string) -> i32 {
        let idx = BTreeMap_str_str_find(self.keys, key)
        if idx < 0 {
            return 0
        }
        return vec_get(self.values, idx)
    }

    fn contains(self, key: string) -> i32 {
        let idx = BTreeMap_str_str_find(self.keys, key)
        if idx < 0 {
            return 0
        }
        return 1
    }
}
