// Contrast: Point returned every iteration → GlobalEscape (no SROA in the hot path).
struct Point {
    x: i32
    y: i32
}

fn mk() -> Point {
    return Point { x: 1, y: 2 }
}

fn main() {
    mut sum = 0
    mut i = 0
    while i < 80000000 {
        let p = mk()
        sum = sum + p.x + p.y
        i = i + 1
    }
    print(sum)
}
