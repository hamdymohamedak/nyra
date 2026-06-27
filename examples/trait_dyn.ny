// Example: static trait impl vs dynamic dispatch (dyn Trait).

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

fn main() {
    let c = Counter { value: 10 }
    print("static: ")
    print(c.add(2))
    print("dyn: ")
    print(call_add(c as dyn Add))
}
