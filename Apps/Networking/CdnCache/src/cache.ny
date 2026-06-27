const CACHE_PORT = 8090
const CACHE_TTL_MS = 60000
const CACHE_DIR = "/tmp/nyra-cdn-cache"

fn CdnCache_key(path, query) {
    if strlen(query) == 0 {
        return path
    }
    return strcat(path, strcat("?", query))
}

fn CdnCache_serve_connection(stream, cache) {
    let mut store = cache
    let mut hops = 0
    while hops < 10 {
        let raw = tcp_read(stream, 65536)
        if strlen(raw) == 0 {
            break
        }
        let ctx = RequestContext_from_raw(raw)
        let mut resp = response_method_not_allowed()
        if ctx.method == METHOD_GET {
            if strcmp(ctx.path, "/health") == 0 {
                resp = response_ok_json("{\"cache\":\"ok\",\"ttl\":true,\"disk\":true}")
            } else {
                let key = CdnCache_key(ctx.path, ctx.query)
                if TtlCache_has(store, key) == 1 {
                    let hit = TtlCache_get(store, key)
                    let body = strcat("{\"hit\":true,\"data\":\"", strcat(hit, "\"}"))
                    resp = response_ok_json(body)
                } else {
                    let origin = strcat("cached:", key)
                    store = TtlCache_put(store, key, origin)
                    let body = strcat("{\"hit\":false,\"data\":\"", strcat(origin, "\"}"))
                    resp = response_ok_json(body)
                }
            }
        }
        let ka = wants_keep_alive(raw)
        tcp_write(stream, build_response(resp, ka))
        if ka == 0 {
            break
        }
        hops = hops + 1
    }
    return store
}

fn CdnCache_run() {
    let mut store = TtlCache_new(CACHE_TTL_MS, CACHE_DIR, 1)
    print(`CDN cache http://127.0.0.1:${CACHE_PORT} (TTL + disk)`)
    let listener = tcp_listen("127.0.0.1", CACHE_PORT)
    if listener.fd < 0 {
        print("bind failed")
        return
    }
    let mut count = 0
    while count < 100 {
        let stream = tcp_accept_wait(listener, 60000)
        if stream.fd < 0 {
            break
        }
        store = CdnCache_serve_connection(stream, store)
        tcp_close_stream(stream)
        count = count + 1
    }
    tcp_close_listener(listener)
}
