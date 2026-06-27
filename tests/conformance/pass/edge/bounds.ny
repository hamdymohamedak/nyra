import "stdlib/testing.ny"

enum Unit { Only }

test fn conf_for_empty_range() {
    let mut sum = 0
    for i in 0..0 {
        sum = sum + i
    }
    assert_eq(sum, 0)
}

test fn conf_while_zero_iterations() {
    let mut n = 0
    while false {
        n = n + 1
    }
    assert_eq(n, 0)
}

test fn conf_nested_arith() {
    let a = 2
    let b = 3
    let c = 4
    let t = (a + b) * c
    assert_eq(t - 2, 18)
}

test fn conf_match_single_arm_enum() {
    let v = match Unit.Only {
        Unit.Only => 1
    }
    assert_eq(v, 1)
}
