// dyn Trait + Send — explicit types
// nyra run examples/trait_dyn_send.typed.ny

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

fn main() -> void {
    let c: Counter = Counter { value: 10 }
    print(call_add(c as dyn Add + Send))
}
