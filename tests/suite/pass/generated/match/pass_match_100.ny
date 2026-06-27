enum Op100 {
    Add
    Sub
    Mul
}
fn main() {
    let op = Op100.Add
    let n = match op {
        Op100.Add => 100
        Op100.Sub => 101
        Op100.Mul => 102
    }
    print(n)
}
