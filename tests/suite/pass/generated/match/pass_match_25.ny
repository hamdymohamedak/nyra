enum Op25 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op25.Add
    let n = match op {
        Op25.Add => 25
        Op25.Sub => 26
        Op25.Mul => 27
    }
    print(n)
}
