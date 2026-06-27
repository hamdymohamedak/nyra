// Struct destructuring and tuple patterns in match (v1.37+).
struct Point {
    x: i32
    y: i32
}

fn sum_point(p: Point) -> i32 {
    return match p {
        Point { x, y } => x + y
    }
}

fn main() -> void {
    let p = Point { x: 3, y: 4 }
    print(sum_point(p))
    let pair = (10, 20)
    let total = match pair {
        (a, b) => a + b
    }
    print(total)
}
