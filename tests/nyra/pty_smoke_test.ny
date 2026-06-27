fn main() -> void {
    print("pty drain smoke")
    let fd = pty_spawn("/bin/bash", 24, 80)
    pty_write(fd, "echo drain-test\n")
    let a = pty_drain(fd, 4096)
    print(`a len check`)
    let b = pty_drain(fd, 4096)
    print(`b done`)
    pty_close(fd)
    print("pty drain smoke done")
}

extern fn pty_spawn(shell: string, rows: i32, cols: i32) -> i32
extern fn pty_write(master: i32, data: string) -> i32
extern fn pty_drain(master: i32, max_bytes: i32) -> string
extern fn pty_close(master: i32) -> void
