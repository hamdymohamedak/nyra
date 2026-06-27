import "../net/tcp.ny"
import "../net/syscall.ny"
import "../net/tls_dev.ny"
import "../net/tls_prod.ny"

extern fn ws_connect(url: string) -> i32
extern fn ws_send_text(fd: i32, text: string) -> i32
extern fn ws_recv_text(fd: i32, max_bytes: i32) -> string
extern fn ws_close(fd: i32) -> void
extern fn ws_listen(host: string, port: i32) -> i32
extern fn ws_listen_tls(cert_path: string, key_path: string, host: string, port: i32) -> i32
extern fn ws_accept_handshake(listener_fd: i32) -> i32
extern fn ws_accept_tls_handshake(tls_listener_fd: i32) -> i32
extern fn ws_send_text_server(fd: i32, text: string) -> i32

struct WebSocket Send {
    fd: i32
}

struct WebSocketListener Send {
    fd: i32
}

fn WebSocket_connect(url: string) -> WebSocket {
    let fd = ws_connect(url)
    return WebSocket { fd: fd }
}

fn ws_listen_on(host: string, port: i32) -> WebSocketListener {
    let fd = ws_listen(host, port)
    return WebSocketListener { fd: fd }
}

fn ws_listen_tls_on(cert_path: string, key_path: string, host: string, port: i32) -> WebSocketListener {
    let fd = ws_listen_tls(cert_path, key_path, host, port)
    return WebSocketListener { fd: fd }
}

fn ws_listen_dev_on(host: string, port: i32) -> WebSocketListener {
    let fd = tls_listen_dev(host, port)
    return WebSocketListener { fd: fd }
}

fn ws_listen_prod_on(host: string, port: i32) -> WebSocketListener {
    let fd = tls_listen_prod(host, port)
    return WebSocketListener { fd: fd }
}

fn ws_accept(listener: WebSocketListener) -> WebSocket {
    let fd = ws_accept_handshake(listener.fd)
    return WebSocket { fd: fd }
}

fn ws_accept_tls(listener: WebSocketListener) -> WebSocket {
    let fd = ws_accept_tls_handshake(listener.fd)
    return WebSocket { fd: fd }
}

impl WebSocket {
    fn send(self, text: string) -> i32 {
        return ws_send_text(self.fd, text)
    }

    fn send_server(self, text: string) -> i32 {
        return ws_send_text_server(self.fd, text)
    }

    fn recv(self, max_bytes: i32) -> string {
        return ws_recv_text(self.fd, max_bytes)
    }

    fn close(self) -> void {
        ws_close(self.fd)
    }
}

impl WebSocketListener {
    fn close(self) -> void {
        sys_close(self.fd)
    }
}
