import "tcp.ny"

extern fn io_register(fd: i32, task_id: i32) -> i32
extern fn io_wait_once(timeout_ms: i32) -> i32
extern fn async_promise_new() -> i32
extern fn async_poll(handle: i32) -> i32

fn poll_register_fd(fd: i32, task: i32) -> i32 {
    return io_register(fd, task)
}

fn poll_wait(timeout_ms: i32) -> i32 {
    return io_wait_once(timeout_ms)
}

fn tcp_relay_once(a: TcpStream, b: TcpStream, max_bytes: i32) -> i32 {
    let from_a = tcp_read(a, max_bytes)
    if strlen(from_a) > 0 {
        tcp_write(b, from_a)
    }
    let from_b = tcp_read(b, max_bytes)
    if strlen(from_b) > 0 {
        tcp_write(a, from_b)
    }
    if strlen(from_a) == 0 && strlen(from_b) == 0 {
        return 0
    }
    return 1
}

fn tcp_relay_bidir(client: TcpStream, backend: TcpStream, rounds: i32) -> void {
    let mut n = 0
    while n < rounds {
        if tcp_relay_once(client, backend, 8192) == 0 {
            break
        }
        n = n + 1
    }
}

fn tcp_relay_poll(client: TcpStream, backend: TcpStream, timeout_ms: i32, max_rounds: i32) -> void {
    let mut rounds = 0
    while rounds < max_rounds {
        poll_wait(timeout_ms)
        if tcp_relay_once(client, backend, 8192) == 0 {
            break
        }
        rounds = rounds + 1
    }
}
