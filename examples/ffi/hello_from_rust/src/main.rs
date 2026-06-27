// POC: link Nyra cdylib when built via `nyra build --cdylib` (see README).
extern "C" {
    fn add(a: i32, b: i32) -> i32;
}

fn main() {
    let sum = unsafe { add(2, 40) };
    assert_eq!(sum, 42);
    println!("hello_from_rust: add(2, 40) = {sum}");
}
