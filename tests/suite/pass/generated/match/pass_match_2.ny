enum Op2 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op2.Add
    let n = match op {
        Op2.Add => 2
        Op2.Sub => 3
        Op2.Mul => 4
    }
    print(n)
}
