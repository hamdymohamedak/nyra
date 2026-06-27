struct Point {
    x: i32
    y: i32
}

fn main() -> void {
    let p: Point = Point { x: 1, y: 2 }
    let mut sum = 0
    let mut i = 0
    while i < 80000000 {
        sum = sum + p.x + p.y
        i = i + 1
    }
    print(sum)
}
