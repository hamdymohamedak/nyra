enum Op1 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op1.Add
    let n = match op {
        Op1.Add => 1
        Op1.Sub => 2
        Op1.Mul => 3
    }
    print(n)
}
