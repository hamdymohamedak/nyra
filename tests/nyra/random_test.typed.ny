// Random smoke tests (explicit types).
import "stdlib/random.ny"
import "stdlib/builtins_math.ny"

fn test_random_range() {
    let r = random_range(1, 6)
    if r < 1 || r > 6 {
        print("fail random_range", r)
    }
}

fn test_random_f64() -> bool {
    let r = random_f64()
    if r < 0.0 || r >= 1.0 {
        print("fail random_f64", r)
        return false
    }
    let m = Math_random()
    if m < 0.0 || m >= 1.0 {
        print("fail Math_random", m)
        return false
    }
    return true
}

fn main() {
    test_random_range()
    if test_random_f64() {
        print("random_test ok")
    }
}
