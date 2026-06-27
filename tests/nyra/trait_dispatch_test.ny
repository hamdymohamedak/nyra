// Trait dynamic dispatch (dyn Trait) — Extended feature.

trait Add {
    fn add(self, other: i32) -> i32
}

struct Counter {
    value: i32
}

impl Add for Counter {
    fn add(self, other: i32) -> i32 {
        return self.value + other
    }
}

fn call_add(g: dyn Add) -> i32 {
    return g.add(1)
}

test fn test_dyn_trait_dispatch() {
    let c = Counter { value: 10 }
    let result = call_add(c as dyn Add)
    assert_eq(result, 11)
}

test fn test_static_trait_impl() {
    let c = Counter { value: 5 }
    assert_eq(c.add(3), 8)
}
