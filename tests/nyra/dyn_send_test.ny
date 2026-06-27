// dyn Trait + Send bounds — v1.5
// nyra test tests/nyra/dyn_send_test.ny

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

fn call_add(g: dyn Add + Send) -> i32 {
    return g.add(1)
}

test fn test_dyn_add_send() {
    let c = Counter { value: 10 }
    assert_eq(call_add(c as dyn Add + Send), 11)
}

test fn test_dyn_add_without_send() {
    let c = Counter { value: 5 }
    assert_eq(call_add(c as dyn Add), 6)
}
