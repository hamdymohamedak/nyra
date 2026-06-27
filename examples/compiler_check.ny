// In-process typecheck via stdlib/compiler.ny (wraps nyra check).
// nyra run examples/compiler_check.ny

fn main() {
    let code = check("examples/control_continue.ny")
    print(code)
}
