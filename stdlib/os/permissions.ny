extern fn rt_perm_getuid() -> i32
extern fn rt_perm_geteuid() -> i32
extern fn rt_perm_drop_to_uid(uid: i32) -> i32
extern fn rt_perm_chroot(path: string) -> i32
extern fn rt_perm_sandbox_seatbelt_available() -> i32

fn perm_getuid() -> i32 {
    return rt_perm_getuid()
}

fn perm_geteuid() -> i32 {
    return rt_perm_geteuid()
}

// Requires appropriate privileges (often root). Returns 0 on success.
fn perm_drop_to_uid(uid: i32) -> i32 {
    return rt_perm_drop_to_uid(uid)
}

fn perm_chroot(path: string) -> i32 {
    return rt_perm_chroot(path)
}

fn perm_sandbox_seatbelt_available() -> bool {
    return rt_perm_sandbox_seatbelt_available() == 1
}
