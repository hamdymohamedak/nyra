fn show(p: &i32) -> void { print(*p) }
fn main() {
    let x = 5
    show(&x)
    print(x)
}
