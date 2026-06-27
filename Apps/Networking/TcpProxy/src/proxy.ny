fn TcpProxy_run() {
    let listen_port_in = input("Listen port [9000]: ")
    let listen_port = if strlen(listen_port_in) == 0 { 9000 } else { str_to_i32(listen_port_in) }
    let backend_host = input("Backend host [127.0.0.1]: ")
    let host = if strlen(backend_host) == 0 { "127.0.0.1" } else { backend_host }
    let backend_port_in = input("Backend port [8080]: ")
    let backend_port = if strlen(backend_port_in) == 0 { 8080 } else { str_to_i32(backend_port_in) }
    print(`Proxy 127.0.0.1:${listen_port} -> ${host}:${backend_port}`)
    let listener = tcp_listen("127.0.0.1", listen_port)
    if listener.fd < 0 {
        print("bind failed")
        return
    }
    let mut sessions = 0
    while sessions < 20 {
        let client = tcp_accept(listener)
        if client.fd < 0 {
            break
        }
        let backend = tcp_connect_timeout(host, backend_port, 5000)
        if backend.fd < 0 {
            tcp_close_stream(client)
            print("backend connect failed")
        } else {
            tcp_relay_poll(client, backend, 100, 32)
            tcp_close_stream(backend)
            tcp_close_stream(client)
            sessions = sessions + 1
        }
    }
    tcp_close_listener(listener)
}
