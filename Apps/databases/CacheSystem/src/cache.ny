const CACHE_CAP = 3

struct LruCache {
    data: HashMap_str_str
    keys: StrVec
    tick: i32
}

fn LruCache_new() {
    return LruCache { data: HashMap_str_str_new(), keys: StrVec_new(), tick: 0 }
}

fn LruCache_touch(cache, key: string) {
    let mut keys = StrVec_new()
    keys = keys.push(key)
    let n = cache.keys.len()
    let mut i = 0
    while i < n {
        let k = cache.keys.get(i)
        if strcmp(k, key) != 0 {
            keys = keys.push(k)
        }
        i = i + 1
    }
    return LruCache { data: cache.data, keys: keys, tick: cache.tick + 1 }
}

fn LruCache_evict_lru(cache) {
    let n = cache.keys.len()
    if n <= CACHE_CAP {
        return cache
    }
    let victim = cache.keys.get(n - 1)
    let mut keys = StrVec_new()
    let mut i = 0
    while i < n - 1 {
        keys = keys.push(cache.keys.get(i))
        i = i + 1
    }
    return LruCache { data: cache.data.insert(victim, ""), keys: keys, tick: cache.tick }
}

fn LruCache_put(cache, key: string, value: string) {
    let had = cache.data.contains(key)
    let mut next = LruCache_touch(cache, key)
    next = LruCache { data: next.data.insert(key, value), keys: next.keys, tick: next.tick }
    if had == 0 {
        next = LruCache_evict_lru(next)
    }
    return next
}

fn LruCache_get(cache, key: string) {
    if cache.data.contains(key) == 0 {
        return "(miss)"
    }
    let v = cache.data.get(key)
    if strlen(v) == 0 {
        return "(miss)"
    }
    return v
}

fn LruCache_keys_line(cache) {
    let n = cache.keys.len()
    let mut out = "["
    let mut i = 0
    while i < n {
        if i > 0 {
            out = strcat(out, ", ")
        }
        out = strcat(out, cache.keys.get(i))
        i = i + 1
    }
    return strcat(out, "]")
}

fn CacheSystem_run() {
    let mut cache = LruCache_new()
    cache = LruCache_put(cache, "a", "1")
    cache = LruCache_put(cache, "b", "2")
    cache = LruCache_put(cache, "c", "3")
    print(`after 3 puts: ${LruCache_keys_line(cache)}`)
    cache = LruCache_put(cache, "d", "4")
    print(`after evict:  ${LruCache_keys_line(cache)}`)
    print(`get a = ${LruCache_get(cache, "a")}`)
    print(`get d = ${LruCache_get(cache, "d")}`)
    cache = LruCache_put(cache, "d", "four")
    print(`touch d:      ${LruCache_keys_line(cache)}`)
}
