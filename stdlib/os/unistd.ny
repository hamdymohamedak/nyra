import "syscall.ny"

// POSIX-style wrappers — extern syscalls live in syscall.ny (no duplicate Nyra defs).

fn os_close(fd: i32) -> i32 {
    return os_close_fd(fd)
}
