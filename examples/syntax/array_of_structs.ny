struct NumberColor {
    number: i32
    color: string
}

fn main() {
    let collections = [
        NumberColor { number: 1, color: "red" },
        NumberColor { number: 2, color: "blue" },
        NumberColor { number: 14, color: "green" },
    ]
    for item in collections {
        print(`Number is ${item.number} and color is ${item.color}`)
    }
}
