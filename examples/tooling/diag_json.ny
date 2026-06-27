fn main() {
    // Intentional type error — run: nyra diag . --json  or  nyra explain E003
    let x: i32 = "not a number"
    print(x)
}
