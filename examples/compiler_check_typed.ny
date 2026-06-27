// In-process typecheck via stdlib/compiler.ny (wraps nyra check).
// nyra run examples/compiler_check_typed.ny

fn main() -> void {
    let code = check("examples/control_continue.ny")
    print(code)
}
