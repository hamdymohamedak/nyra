const CHAT_PORT = 7777

fn ChatClient_run() {
    let host_in = input("Server [127.0.0.1]: ")
    let host = if strlen(host_in) == 0 { "127.0.0.1" } else { host_in }
    let stream = tcp_connect(host, CHAT_PORT)
    if stream.fd < 0 {
        print("connect failed — start ChatServer first")
        return
    }
    let banner = tcp_read(stream, 256)
    print(banner)
    let nick = input("Nick: ")
    tcp_write(stream, nick)
    print("Messages (/quit to leave)")
    let mut alive = 1
    while alive == 1 {
        let msg = input("you> ")
        if strlen(msg) > 0 {
            tcp_write(stream, msg)
            if strcmp(msg, "/quit") == 0 {
                alive = 0
            } else {
                let ack = tcp_read(stream, 64)
                if strlen(ack) > 0 {
                    print(ack)
                }
            }
        }
    }
    tcp_close_stream(stream)
}
