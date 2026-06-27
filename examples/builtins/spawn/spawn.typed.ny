allow_extended
fn main() -> void {
    let n: i32 = 42
    spawn {
        print(n)
    }
    print(0)
}
