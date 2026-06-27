// run-stdout: 3
struct Point { x: i32 y: i32 }
fn main() {
    let p = Point { x: 1 y: 2 }
    print(p.x + p.y)
}
