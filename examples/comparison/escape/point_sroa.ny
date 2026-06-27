// Escape analysis: Point is NoEscape → SROA (no struct alloca in @main).
struct Point {
    x: i32
    y: i32
}

fn main() {
    let p = Point { x: 1, y: 2 }
    mut sum = 0
    mut i = 0
    while i < 80000000 {
        sum = sum + p.x + p.y
        i = i + 1
    }
    print(sum)
}
