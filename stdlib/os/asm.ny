import "syscall.ny"

// Nyra inline assembly: use inside unsafe { asm "template" }
// Example:
//   unsafe { asm "nop" }
//
// For common ops, C helpers are also available:

fn cpu_nop() -> void {
    asm_nop()
}

fn cpu_pause() -> void {
    asm_pause()
}
