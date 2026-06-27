struct NumberColor {
    number: i32
    color: string
}

fn by_number(a: NumberColor, b: NumberColor) -> i32 {
    return a.number - b.number
}

fn main() {
    let collections = [
        NumberColor { number: 14, color: "#f7d531" },
        NumberColor { number: 2, color: "#4c2600" },
        NumberColor { number: 40, color: "#f15a24" },
        NumberColor { number: 1, color: "#ff0099" },
    ]
    let sorted = collections.sort_by(by_number)
    for i in sorted {
        print(`Number is ${i.number}`, color: i.color)
    }
}
