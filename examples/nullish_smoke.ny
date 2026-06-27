import "stdlib/option.ny"

fn main() {
    let x = Option.None
    let y = x ?? 42
    let z = Option.Some(99)
    let w = z ?? 0
    print(y)
    print(w)
}
