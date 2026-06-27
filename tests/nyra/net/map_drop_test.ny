fn main() {
    let mut store = TtlCache_new(10000, "", 0)
    store = TtlCache_put(store, "one", "alpha")
    store = TtlCache_put(store, "two", "beta")
    if TtlCache_has(store, "one") != 1 || TtlCache_has(store, "two") != 1 {
        print("FAIL ttl put chain")
        return
    }
    let m = HashMap_str_i32_new()
    let m2 = m.insert("x", 42)
    if m2.get("x") != 42 {
        print("FAIL map i32")
        return
    }
    print("map_drop_test ok")
}
