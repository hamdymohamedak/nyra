/// Greets the user by name.
fn greet(name: string) {
    print(strcat("hello, ", name))
}

/// A point in 2D space.
struct Point {
    x: i32
    y: i32
}

fn main() {
    greet("nyra")
    let p = Point { x: 1, y: 2 }
    print(p.x)
}
