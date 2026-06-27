allow_extended

const CHAT_PORT = 7777
const MAX_CLIENTS = 32

fn ChatServer_loop(inbox: ptr, mut hub: TcpHub) {
    let mut served = 0
    while served < MAX_CLIENTS {
        let fd = channel_recv(inbox)
        hub = hub.add(fd)
        let stream = TcpStream { fd: fd }
        tcp_write(stream, "Welcome — enter nick:\r\n")
        let nick_raw = tcp_read(stream, 256)
        let nick = if strlen(nick_raw) == 0 { "anon" } else { nick_raw }
        let join = strcat(strcat("** ", nick), " joined\r\n")
        hub = hub.broadcast(join)
        let mut alive = 1
        while alive == 1 {
            tcp_write(stream, "> ")
            let msg = tcp_read(stream, 4096)
            if strlen(msg) == 0 || strcmp(msg, "/quit") == 0 {
                alive = 0
            } else {
                let line = strcat(strcat(strcat(nick, "> "), msg), "\r\n")
                hub = hub.broadcast(line)
                tcp_write(stream, "ok\r\n")
            }
        }
        hub = hub.remove(fd)
        tcp_close_stream(stream)
        print(`${nick} left`)
        served = served + 1
    }
}

fn ChatServer_run() {
    let inbox = channel_new()
    spawn {
        let mut hub = TcpHub_new(MAX_CLIENTS)
        ChatServer_loop(inbox, hub)
    }
    let listener = tcp_listen("127.0.0.1", CHAT_PORT)
    if listener.fd < 0 {
        print("bind failed — port in use?")
        return
    }
    print(`ChatServer on 127.0.0.1:${CHAT_PORT} (spawn + TcpHub capture)`)
    let mut clients = 0
    while clients < MAX_CLIENTS {
        print("waiting for client...")
        let stream = tcp_accept_wait(listener, 120000)
        if stream.fd < 0 {
            break
        }
        channel_send(inbox, stream.fd)
        clients = clients + 1
    }
    tcp_close_listener(listener)
}
