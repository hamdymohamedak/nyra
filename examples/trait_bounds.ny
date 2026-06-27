// Generic fn with trait bounds — nyra run examples/trait_bounds.ny
// nyra test tests/nyra/trait_bounds_test.ny

trait Greet {
    fn hello(self) -> i32
}

struct User {
    score: i32
}

impl Greet for User {
    fn hello(self) -> i32 {
        return self.score + 100
    }
}

fn call_greet<T: Greet>(x: T) -> i32 {
    return x.hello()
}

fn main() {
    let u = User { score: 7 }
    print(call_greet(u))
}
