struct HashMap_str_i32 {
    handle: ptr
}

extern fn map_str_i32_new() -> ptr
extern fn map_str_i32_insert(m: ptr, key: string, value: i32) -> void
extern fn map_str_i32_get(m: ptr, key: string) -> i32
extern fn map_str_i32_contains(m: ptr, key: string) -> i32
extern fn map_str_i32_free(m: ptr) -> void

fn HashMap_str_i32_new() -> HashMap_str_i32 {
    return HashMap_str_i32 { handle: map_str_i32_new() }
}

impl HashMap_str_i32 {
    fn insert(self, key: string, value: i32) -> HashMap_str_i32 {
        map_str_i32_insert(self.handle, key, value)
        return HashMap_str_i32 { handle: self.handle }
    }

    fn get(self, key: string) -> i32 {
        return map_str_i32_get(self.handle, key)
    }

    fn contains(self, key: string) -> i32 {
        return map_str_i32_contains(self.handle, key)
    }
}

impl Drop for HashMap_str_i32 {
    fn drop(self) -> void {
        map_str_i32_free(self.handle)
    }
}

test fn test_hashmap_insert_chain() {
    let m = HashMap_str_i32_new().insert("a", 1).insert("b", 2)
    assert_eq(m.get("a"), 1)
    assert_eq(m.get("b"), 2)
    assert_eq(m.contains("a"), 1)
    assert_eq(m.contains("missing"), 0)
}

test fn test_hashmap_field_chain() {
    let m = HashMap_str_i32_new().insert("x", 42)
    let m2 = m.insert("y", 7)
    assert_eq(m2.get("x"), 42)
    assert_eq(m2.get("y"), 7)
}
