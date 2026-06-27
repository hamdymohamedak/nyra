allow_extended

// Type inference: optional annotations for the programmer, mandatory for the compiler.
// See docs/conformance/inference.md (CONF-INF-*)

fn id<T>(x: T) -> T {
    return x
}

fn run() {
    print(1)
}

fn twice(x: i32) {
    return x + x
}

struct Point {
    x: i32
    y: i32
}

fn main() {
    let n = 42
    print(n)

    print(id(7))
    print(id("nyra"))

    run()
    print(twice(3))

    let p = Point(1, 2)
    print(p.x)
}
