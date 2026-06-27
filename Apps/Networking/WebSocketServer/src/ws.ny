const WS_PORT = 9001

fn WebSocketServer_run() {
    print(`WebSocket server ws://127.0.0.1:${WS_PORT}`)
    print("(wss: ws_listen_tls_on(cert, key, host, port) + ws_accept_tls)")
    let listener = ws_listen_on("127.0.0.1", WS_PORT)
    if listener.fd < 0 {
        print("bind failed")
        return
    }
    let mut served = 0
    while served < 5 {
        print("waiting for WebSocket client...")
        let ws = ws_accept(listener)
        if ws.fd < 0 {
            break
        }
        let msg = ws.recv(4096)
        if strlen(msg) > 0 {
            print(strcat("recv: ", msg))
            ws.send_server(strcat("echo: ", msg))
        }
        ws.close()
        served = served + 1
    }
    listener.close()
}
