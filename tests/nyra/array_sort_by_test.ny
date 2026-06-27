struct NumberColor {
    number: i32
    color: string
}

fn by_number(a: NumberColor, b: NumberColor) -> i32 {
    return a.number - b.number
}

fn main() {
    let items = [
        NumberColor { number: 14, color: "g" },
        NumberColor { number: 2, color: "b" },
        NumberColor { number: 40, color: "o" },
    ]
    let sorted = items.sort_by(by_number)
    assert_eq(sorted[0].number, 2)
    assert_eq(sorted[1].number, 14)
    assert_eq(sorted[2].number, 40)
    assert_str_eq(sorted[0].color, "b")

    let nums = [10, 1, 2, 8, 5]
    let asc = nums.sort_by((a, b) => a - b)
    assert_eq(asc[0], 1)
    assert_eq(asc[4], 10)

    let desc = nums.sort_by((a, b) => b - a)
    assert_eq(desc[0], 10)
    assert_eq(desc[4], 1)
}
