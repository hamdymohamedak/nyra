enum Op200 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op200.Add
    let n = match op {
        Op200.Add => 200
        Op200.Sub => 201
        Op200.Mul => 202
    }
    print(n)
}
