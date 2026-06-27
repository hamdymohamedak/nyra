// Low-level memory primitives for unsafe / no_std / embedded code.
// Link with libc or provide your own symbols when using --freestanding.

extern fn malloc(size: i64) -> ptr
extern fn free(p: ptr) -> void
extern fn memcpy(dst: ptr, src: ptr, nbytes: i64) -> ptr
extern fn memset(dst: ptr, byte: i32, nbytes: i64) -> ptr

// Volatile MMIO access (hardware registers, device memory).
extern fn volatile_load_i32(addr: ptr) -> i32
extern fn volatile_store_i32(addr: ptr, value: i32) -> void
extern fn volatile_load_u32(addr: ptr) -> u32
extern fn volatile_store_u32(addr: ptr, value: u32) -> void
