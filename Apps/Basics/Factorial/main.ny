import "src/ASCII.ny"
import "src/logic.ny"

fn main() {
    print("=== Factorial ===", color: bold)
    Factorial_run(10)
    print_ascii()
}
