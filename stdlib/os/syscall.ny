// Raw OS syscall layer (C runtime). Distinct from net sys_* (sockets).
// Prefer unistd.ny wrappers for everyday use.

extern fn os_syscall6(num: i64, a0: i64, a1: i64, a2: i64, a3: i64, a4: i64, a5: i64) -> i64

extern fn os_getpid() -> i32
extern fn os_exit(code: i32) -> void
extern fn os_read(fd: i32, buf: ptr, count: i64) -> i64
extern fn os_write(fd: i32, buf: ptr, count: i64) -> i64
extern fn os_close_fd(fd: i32) -> i32

// Inline asm helpers (C __asm__); use Nyra `asm "..."` for custom templates in unsafe blocks.
extern fn asm_nop() -> void
extern fn asm_pause() -> void
