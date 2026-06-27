// Stdlib I/O (v0.3): buffered stdout via write/println/flush builtins.
// Low-level runtime symbols for FFI or advanced use.
extern fn stdout_write_str(s: string) -> void
extern fn stdout_writeln_str(s: string) -> void
extern fn stdout_write_i32(n: i32) -> void
extern fn stdout_writeln_i32(n: i32) -> void
extern fn stdout_flush() -> void
extern fn println(msg: string) -> i32
