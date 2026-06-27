const CHAT_PORT = 7777

fn Chat_broadcast(log, nick, msg){
    let line = strcat(strcat(strcat(nick, "> "), msg), "")
    print(line)
    return log.push(line)
}

fn Chat_dump_history(log){
    let n = log.len()
    if n == 0 {
        print("(no messages yet)")
        return
    }
    print("--- history ---")
    let mut i = 0
    while i < n {
        print(log.get(i))
        i = i + 1
    }
    print("---------------")
}

fn Chat_server(){
    let listener = tcp_listen("127.0.0.1", CHAT_PORT)
    if listener.fd < 0 {
        print("bind failed — port in use?")
        return
    }
    print(`server listening on 127.0.0.1:${CHAT_PORT}`)
    let mut log = StrVec_new()
    let mut clients = 0
    while clients < 10 {
        print("waiting for client...")
        let stream = tcp_accept(listener)
        if stream.fd < 0 {
            break
        }
        clients = clients + 1
        tcp_write(stream, "Welcome to NyChat — enter nick:\r\n")
        let nick_raw = tcp_read(stream, 256)
        let nick = if strlen(nick_raw) == 0 { "anon" } else { nick_raw }
        Chat_dump_history(log)
        let welcome = strcat(strcat("** ", nick), " joined")
        print(welcome)
        log = log.push(welcome)
        let mut alive = 1
        while alive == 1 {
            tcp_write(stream, "> ")
            let msg = tcp_read(stream, 4096)
            if strlen(msg) == 0 {
                alive = 0
            } else {
                if strcmp(msg, "/quit") == 0 {
                    alive = 0
                } else {
                    log = Chat_broadcast(log, nick, msg)
                    tcp_write(stream, "ok\r\n")
                }
            }
        }
        tcp_close_stream(stream)
        print(`${nick} disconnected`)
    }
    tcp_close_listener(listener)
}

fn Chat_client(){
    let host_in = input("Server host [127.0.0.1]: ")
    let host = if strlen(host_in) == 0 { "127.0.0.1" } else { host_in }
    let stream = tcp_connect(host, CHAT_PORT)
    if stream.fd < 0 {
        print("connect failed — is server running?")
        return
    }
    let banner = tcp_read(stream, 256)
    print(banner)
    let nick = input("Nick: ")
    tcp_write(stream, nick)
    print("Type messages (/quit to leave)")
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

fn NyChat_run(){
    print("1 = server   2 = client")
    let mode = input("Mode: ")
    if strcmp(mode, "1") == 0 {
        Chat_server()
    } else {
        if strcmp(mode, "2") == 0 {
            Chat_client()
        } else {
            print("unknown mode")
        }
    }
}
