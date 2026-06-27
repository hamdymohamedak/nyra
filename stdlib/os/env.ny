extern fn rt_os_getenv(name: string) -> string

// Named os_getenv — not `getenv` (collides with libc at link time).
fn os_getenv(name: string) -> string {
    return rt_os_getenv(name)
}
