// Random + metaprogramming smoke tests (zero-types).
import "stdlib/random.ny"
import "stdlib/builtins_math.ny"

fn test_random_i32() {
    let a = random()
    let b = Random()
    if a == 0 && b == 0 {
        print("warn random both zero")
    }
}

fn test_random_range() {
    let r = random_range(1, 6)
    if r < 1 || r > 6 {
        print("fail random_range", r)
    }
}

fn test_random_f64() {
    let r = random_f64()
    if r < 0.0 || r >= 1.0 {
        print("fail random_f64", r)
    }
    let m = Math_random()
    if m < 0.0 || m >= 1.0 {
        print("fail Math_random", m)
    }
}

fn main() {
    test_random_i32()
    test_random_range()
    test_random_f64()
    print("random_test ok")
}
