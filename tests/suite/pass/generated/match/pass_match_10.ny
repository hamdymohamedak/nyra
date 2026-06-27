enum Op10 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op10.Add
    let n = match op {
        Op10.Add => 10
        Op10.Sub => 11
        Op10.Mul => 12
    }
    print(n)
}
