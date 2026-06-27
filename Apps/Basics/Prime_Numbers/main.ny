import "src/ASCII.ny"
import "src/logic.ny"

fn main() {
    print("=== Prime numbers (≤100) ===", color: bold)
    Prime_run(100)
    print_ascii()
}
