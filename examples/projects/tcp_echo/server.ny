allow_extended
import "../../../stdlib/net.ny"
import "../../../stdlib/strings.ny"

fn main() {
    let listener = tcp_listen("127.0.0.1", 19090)
    if listener.fd < 0 {
        print(0)
    } else {
        let task = tcp_accept_async(listener.fd)
        let client_fd = await task
        if client_fd < 0 {
            tcp_close_listener(listener)
            print(0)
        } else {
            let client = TcpStream { fd: client_fd }
            let msg = tcp_read(client, 256)
            if strlen(msg) > 0 {
                tcp_write(client, msg)
            }
            tcp_close_stream(client)
            tcp_close_listener(listener)
            print(1)
        }
    }
}
