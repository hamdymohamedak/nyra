fn f(a: i32, b: i32) -> i32 { return a + b }
fn main() {
    print(f(1)) //~ ERROR expects 2 arguments
}
