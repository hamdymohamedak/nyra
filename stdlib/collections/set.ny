import "../map.ny"

struct HashSet_str {
    map: HashMap_str_i32
}

fn HashSet_str_new() -> HashSet_str {
    return HashSet_str { map: HashMap_str_i32_new() }
}

impl HashSet_str {
    fn insert(self, key: string) -> HashSet_str {
        let map = self.map.insert(key, 1)
        return HashSet_str { map: map }
    }

    fn contains(self, key: string) -> i32 {
        return self.map.contains(key)
    }
}

impl Drop for HashSet_str {
    fn drop(self) -> void {
    }
}
