// Multi-method dyn Trait demo — zero-types
// nyra run examples/trait_dyn_multi.ny

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

fn main() {
    let c = Counter { value: 10 }
    let g = c as dyn Calc
    print(g.add(2))
    print(g.mul(3))
}
