import "stdlib/testing.ny"

test fn conf_if_expr_value() {
    let pick = if 3 > 1 { 42 } else { 0 }
    assert_eq(pick, 42)
}

test fn conf_nested_if_expr() {
    let outer = if true {
        if false { 1 } else { 5 }
    } else {
        0
    }
    assert_eq(outer, 5)
}
