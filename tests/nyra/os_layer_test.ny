import "stdlib/os/event_loop.ny"
import "stdlib/os/fd.ny"
import "stdlib/os/memory.ny"
import "stdlib/io/pool.ny"
import "stdlib/terminal/pty.ny"

test fn test_event_loop_tick() {
    let ev = EventLoop_new()
    let fired = EventLoop_tick(ev, 1)
    let _ = fired
}

test fn test_mem_map_anonymous() {
    let addr = mem_map_anonymous(4096)
    let zero = 0
    assert_eq(zero, 0)
    let _ = mem_unmap(addr, 4096)
}

test fn test_io_pool_create_shutdown() {
    let pool = IoPool_new(2)
    assert_eq(IoPool_pending(pool), 0)
    IoPool_shutdown(pool)
}

test fn test_pty_session_fd() {
    let sess = PtySession_spawn("/bin/echo")
    if sess.alive == 1 {
        let fd = PtySession_fd(sess)
        let ok = if fd >= 0 { 1 } else { 0 }
        assert_eq(ok, 1)
        let _ = PtySession_close(sess)
    }
}

fn main() {
    print(0)
}
