import "types.ny"
import "ops.ny"

fn main() {
    let c = Calculator { value: 0 }
    let c2 = add_calc(c, 10)
    print(c2.value)
}
