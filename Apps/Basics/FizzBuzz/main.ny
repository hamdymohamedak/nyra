import "src/ASCII.ny"
import "src/logic.ny"

fn main() {
    print("=== FizzBuzz (1..30) ===", color: bold)
    FizzBuzz_run(30)
    print_ascii()
}
