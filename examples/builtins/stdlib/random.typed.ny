import "stdlib/random.ny"

fn main() {
    print(random())
    print(random(1, 6))
    let min: i64 = 50
    let max: i64 = 100
    print(random(min, max))
    print(random_f64())
    print(random_f64(0.0, 1.0))
}
