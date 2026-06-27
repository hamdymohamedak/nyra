struct NumberColor {
    number: i32
    color: string
}

test fn test_array_of_named_struct_literals() {
    let items = [
        NumberColor { number: 1, color: "red" },
        NumberColor { number: 2, color: "blue" },
    ]
    assert_eq(items.len(), 2)
    assert_eq(items[0].number, 1)
    assert_eq(items[1].number, 2)
    assert_eq(items[1].color.length(), 4)
}

test fn test_array_of_anonymous_struct_literals() {
    let items = [
        { number: 10, color: "cyan" },
        { number: 20, color: "magenta" },
    ]
    assert_eq(items.len(), 2)
    assert_eq(items[0].number, 10)
    assert_eq(items[1].number, 20)
    assert_eq(items[1].color.length(), 7)
}
