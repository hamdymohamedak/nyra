enum Op5 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op5.Add
    let n = match op {
        Op5.Add => 5
        Op5.Sub => 6
        Op5.Mul => 7
    }
    print(n)
}
