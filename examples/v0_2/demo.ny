module example.v0_2

macro double(x) {
    $x + $x
}

trait Add {
    fn add(self, other: i32) -> i32
}

struct Counter {
    value: i32
}

impl Counter {
    fn new() -> Counter {
        Counter { value: 0 }
    }
}

impl Add for Counter {
    fn add(self, other: i32) -> i32 {
        self.value + other
    }
}

fn main() {
    let n = double(3)
    print(n)
}
