mod common;
use common::compile;

#[test]
fn serde_dump_probe() {
    let src = r#"
struct User {
    name: string
    age: i32
}
fn main() {
    let u = User { name: "Ada", age: 30 }
    let blob = User_bin_encode(u)
    let u2 = User_bin_decode(blob)
    println(u2.name)
}
"#;
    let out = compile(src);
    let ir = out.llvm_ir.as_ref().expect("llvm");
    for line in ir.lines() {
        if line.contains("User_bin_decode") || line.contains("bin_dec") || line.contains("define") && line.contains("User") {
            println!("{}", line);
        }
    }
}
