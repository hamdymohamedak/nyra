// Multi-method trait object dispatch — typed
// nyra test tests/nyra/trait_dyn_multi_test.typed.ny

trait Calc {
    fn add(self, other: i32) -> i32
    fn mul(self, other: i32) -> i32
}

struct Counter {
    value: i32
}

impl Calc for Counter {
    fn add(self, other: i32) -> i32 {
        return self.value + other
    }
    fn mul(self, other: i32) -> i32 {
        return self.value * other
    }
}

fn call_calc(g: dyn Calc) -> i32 {
    let sum: i32 = g.add(2)
    let prod: i32 = g.mul(3)
    return sum + prod
}

test fn test_dyn_multi_method() {
    let c = Counter { value: 10 }
    let result: i32 = call_calc(c as dyn Calc)
    assert_eq(result, 42)
}
