import "stdlib/testing.ny"

enum Option_i32 {
    None,
    Some(i32),
}

test fn conf_adt_some_payload() {
    let x = Option_i32.Some(42)
    let n = match x {
        Option_i32.Some(v) => v
        Option_i32.None => 0
    }
    assert_eq(n, 42)
}

test fn conf_adt_none_arm() {
    let x = Option_i32.None
    let n = match x {
        Option_i32.Some(_v) => 1
        Option_i32.None => 99
    }
    assert_eq(n, 99)
}
