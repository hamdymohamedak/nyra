// Trait bounds on generic type parameters — nyra test tests/nyra/trait_bounds_test.ny

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

fn sum_one<T: Add>(x: T) -> i32 {
    return x.add(1)
}

test fn test_trait_bound_generic_call() {
    let c = Counter { value: 10 }
    assert_eq(sum_one(c), 11)
}
