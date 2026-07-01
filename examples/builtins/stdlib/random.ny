import "stdlib/random.ny"

fn main() {
    print(random())
    print(random(1, 6))
    print(random_f64())
    print(random_f64(0.0, 1.0))
}
