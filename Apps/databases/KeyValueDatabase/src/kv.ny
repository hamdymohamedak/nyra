const KV_FILE = "kv.store"

struct KvStore {
    data: HashMap_str_str
    keys: StrVec
}

fn KvStore_new() {
    return KvStore { data: HashMap_str_str_new(), keys: StrVec_new() }
}

fn KvStore_line(key, value) {
    return strcat(key, strcat("=", value))
}

fn KvStore_load() {
    if exists(KV_FILE) == 0 {
        return KvStore_new()
    }
    let text = read_file(KV_FILE)
    let lines = StrVec_from_lines(text)
    let mut store = KvStore_new()
    let n = lines.len()
    let mut i = 0
    while i < n {
        let line = lines.get(i)
        let pos = strstr_pos(line, "=")
        if pos >= 0 {
            let key = substring(line, 0, pos)
            let line_len = strlen(line)
            let value = substring(line, pos + 1, line_len - pos - 1)
            store = KvStore_set(store, key, value)
        }
        i = i + 1
    }
    return store
}

fn KvStore_save(store) {
    let mut lines = StrVec_new()
    let n = store.keys.len()
    let mut i = 0
    while i < n {
        let k = store.keys.get(i)
        lines = lines.push(KvStore_line(k, store.data.get(k)))
        i = i + 1
    }
    write_file(KV_FILE, StrVec_join_lines(lines))
}

fn KvStore_set(store, key, value) {
    let mut keys = store.keys
    if store.data.contains(key) == 0 {
        keys = keys.push(key)
    }
    return KvStore { data: store.data.insert(key, value), keys: keys }
}

fn KvStore_get(store, key) {
    if store.data.contains(key) == 0 {
        return "(nil)"
    }
    return store.data.get(key)
}

fn KvStore_run() {
    let mut store = KvStore_load()
    store = KvStore_set(store, "alpha", "one")
    store = KvStore_set(store, "beta", "two")
    KvStore_save(store)
    print(`alpha = ${KvStore_get(store, "alpha")}`)
    print(`beta  = ${KvStore_get(store, "beta")}`)
    print(`gamma = ${KvStore_get(store, "gamma")}`)
    print(`persisted to ${KV_FILE}`)
}
