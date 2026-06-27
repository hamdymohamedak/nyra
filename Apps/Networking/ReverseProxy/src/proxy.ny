const PROXY_PORT = 8088

fn ReverseProxy_handle(stream, upstream) {
    let mut hops = 0
    while hops < 6 {
        let raw = tcp_read(stream, 65536)
        if strlen(raw) == 0 {
            break
        }
        let ctx = RequestContext_from_raw(raw)
        let mut resp = response_method_not_allowed()
        let url = strcat(upstream, ctx.path)
        if ctx.method == METHOD_GET {
            let body = get(url)
            resp = response_text(STATUS_OK, body)
        } else {
            if ctx.method == METHOD_POST {
                let r = post(url, ctx.body)
                resp = HttpResponse { status: r.status, body: r.body, content_type: r.content_type }
            }
        }
        let ka = wants_keep_alive(raw)
        tcp_write(stream, build_response(resp, ka))
        if ka == 0 {
            break
        }
        hops = hops + 1
    }
}

fn ReverseProxy_run() {
    let upstream_in = input("Upstream base URL [http://127.0.0.1:8080]: ")
    let upstream = if strlen(upstream_in) == 0 { "http://127.0.0.1:8080" } else { upstream_in }
    print(`Reverse proxy http://127.0.0.1:${PROXY_PORT} -> ${upstream}`)
    let listener = tcp_listen("127.0.0.1", PROXY_PORT)
    if listener.fd < 0 {
        print("bind failed")
        return
    }
    let mut count = 0
    while count < 50 {
        let stream = tcp_accept_wait(listener, 60000)
        if stream.fd < 0 {
            break
        }
        ReverseProxy_handle(stream, upstream)
        tcp_close_stream(stream)
        count = count + 1
    }
    tcp_close_listener(listener)
}
