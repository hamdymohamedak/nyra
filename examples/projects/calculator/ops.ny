import "types.ny"

fn add_calc(c: Calculator, n: i32) -> Calculator {
    return Calculator { value: c.value + n }
}
