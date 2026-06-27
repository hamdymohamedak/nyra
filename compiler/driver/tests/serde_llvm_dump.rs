mod common;
use common::compile;

#[test]
fn serde_llvm_dump() {
    let src = r#"
struct User {
    name: string
    age: i32
}
fn main() {
    let u = User { name: "Ada", age: 30 }
    let u2 = User_bin_decode(User_bin_encode(u))
    println(u2.name)
}
"#;
    let ir = compile(src).llvm_ir.unwrap();
    std::fs::write("/tmp/user_llvm.ll", &ir).ok();
    let mut in_fn = false;
    for line in ir.lines() {
        if line.starts_with("define %User @User_bin_decode") {
            in_fn = true;
        }
        if in_fn {
            println!("{}", line);
            if line == "}" && in_fn {
                break;
            }
        }
    }
}
