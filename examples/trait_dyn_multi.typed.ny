// Multi-method dyn Trait demo — typed
// nyra run examples/trait_dyn_multi.typed.ny

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
    let g: dyn Calc = c as dyn Calc
    print(g.add(2))
    print(g.mul(3))
}
