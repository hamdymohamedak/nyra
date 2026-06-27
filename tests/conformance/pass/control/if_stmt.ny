import "stdlib/testing.ny"

test fn conf_if_true_branch() {
    let mut n = 0
    if 1 == 1 {
        n = 1
    }
    assert_eq(n, 1)
}

test fn conf_if_else() {
    let mut n = 0
    if false {
        n = 99
    } else {
        n = 2
    }
    assert_eq(n, 2)
}

test fn conf_if_print_path() {
    let x = if true { 1 } else { 0 }
    assert_eq(x, 1)
}
