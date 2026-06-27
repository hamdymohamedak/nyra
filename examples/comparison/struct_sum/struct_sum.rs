struct Point {
    x: i32,
    y: i32,
}

fn main() {
    let n: i32 = 80_000_000;
    let p = Point { x: 1, y: 2 };
    let mut sum: i64 = 0;
    for _ in 0..n {
        sum += (p.x + p.y) as i64;
    }
    println!("{}", sum);
}
