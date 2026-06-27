// f32 — games, graphics, less memory than f64

fn main() {
    let scale = 0.5f32
    let offset = 1.0f32
    print(scale + offset)

    let coords = Point { x: 1.5f32, y: 2.5f32 }
    print(coords.x + coords.y)
}

struct Point {
    x: f32
    y: f32
}
