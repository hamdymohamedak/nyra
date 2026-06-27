allow_extended
fn main() {
    let n = 42
    spawn {
        print(n)
    }
    print(0)
}
