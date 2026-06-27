import "../../../stdlib/net.ny"
import "../../../stdlib/strings.ny"

fn main() {
    let stream = tcp_connect("127.0.0.1", 19090)
    if stream.fd < 0 {
        print(0)
        return
    }
    tcp_write(stream, "ping")
    let reply = tcp_read(stream, 64)
    tcp_close_stream(stream)
    if strcmp(reply, "ping") == 0 {
        print(1)
    } else {
        print(0)
    }
}
