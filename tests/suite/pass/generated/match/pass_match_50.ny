enum Op50 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op50.Add
    let n = match op {
        Op50.Add => 50
        Op50.Sub => 51
        Op50.Mul => 52
    }
    print(n)
}
