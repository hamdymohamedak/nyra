enum Op360 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op360.Add
    let n = match op {
        Op360.Add => 360
        Op360.Sub => 361
        Op360.Mul => 362
    }
    print(n)
}
