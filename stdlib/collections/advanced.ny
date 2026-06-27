import "../map.ny"
import "../vec.ny"
import "../collections/queue.ny"
import "../collections/btree_map.ny"

struct BTreeSet_str {
    inner: HashMap_str_i32
}

fn BTreeSet_str_new() -> BTreeSet_str {
    return BTreeSet_str { inner: HashMap_str_i32_new() }
}

impl BTreeSet_str {
    fn insert(self, key: string) -> BTreeSet_str {
        let inner = self.inner.insert(key, 1)
        return BTreeSet_str { inner: inner }
    }

    fn contains(self, key: string) -> i32 {
        return self.inner.contains(key)
    }
}

fn Deque_i32_new() -> Queue_i32 {
    return Queue_i32_new()
}

struct PriorityQueue_i32 {
    items: ptr
}

fn PriorityQueue_i32_new() -> PriorityQueue_i32 {
    return PriorityQueue_i32 { items: Vec_i32_new() }
}

impl PriorityQueue_i32 {
    fn push(self, x: i32) -> PriorityQueue_i32 {
        let items = vec_push(self.items, x)
        return PriorityQueue_i32 { items: items }
    }

    fn pop_max(self) -> i32 {
        let n = vec_len(self.items)
        if n <= 0 {
            return 0
        }
        let mut best = vec_get(self.items, 0)
        let mut i = 1
        while i < n {
            let v = vec_get(self.items, i)
            if v > best {
                best = v
            }
            i = i + 1
        }
        return best
    }
}
