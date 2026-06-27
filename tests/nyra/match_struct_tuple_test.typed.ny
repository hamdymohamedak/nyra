struct Point {
    x: i32
    y: i32
}

fn sum_point(p: Point) -> i32 {
    return match p {
        Point { x, y } => x + y
    }
}

fn main() {
    let p: Point = Point { x: 3, y: 4 }
    print(sum_point(p))
    let pair: (i32, i32) = (10, 20)
    let total: i32 = match pair {
        (a, b) => a + b
    }
    print(total)
}
