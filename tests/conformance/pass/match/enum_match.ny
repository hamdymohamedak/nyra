import "stdlib/testing.ny"

enum Color { Red, Green, Blue }

test fn conf_match_enum_unit() {
    let c = Color.Green
    let n = match c {
        Color.Red => 1
        Color.Green => 2
        Color.Blue => 3
    }
    assert_eq(n, 2)
}

test fn conf_match_exhaustive_arms() {
    let c = Color.Blue
    let n = match c {
        Color.Red => 10
        Color.Green => 20
        Color.Blue => 30
    }
    assert_eq(n, 30)
}
