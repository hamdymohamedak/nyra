struct Point {
    x: i32
}
fn main() {
    let p = Point { x: 1 y: 2 } //~ ERROR Unknown field
}
