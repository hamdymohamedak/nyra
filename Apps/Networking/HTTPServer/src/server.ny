const DEFAULT_PORT = 8080
const MAX_REQUESTS = 100

fn HTTPServer_handler(slot, ctx) {
    if slot == 1 {
        return response_ok_json("{\"status\":\"ok\",\"app\":\"HTTPServer\"}")
    }
    if slot == 2 {
        let ms = instant_now()
        let body = strcat("{\"ms\":", strcat(i32_to_string(ms), "}"))
        return response_ok_json(body)
    }
    if slot == 3 && ctx.method == METHOD_POST {
        return response_json(STATUS_OK, strcat("{\"echo\":", strcat(ctx.body, "}")))
    }
    if slot == 4 {
        return response_html(STATUS_OK, "<h1>HTTPServer</h1><p>handler router slots</p>")
    }
    return response_not_found()
}

fn HTTPServer_run() {
    let host_in = input("Host [127.0.0.1]: ")
    let host = if strlen(host_in) == 0 { "127.0.0.1" } else { host_in }
    let port_in = input("Port [8080]: ")
    let port = if strlen(port_in) == 0 { DEFAULT_PORT } else { str_to_i32(port_in) }
    print(`Listening http://${host}:${port} (serve_handlers, zero-types handler)`)
    let mut router = HttpRouter_new()
    router = HttpRouter_register_slot(router, METHOD_GET, "/health", 1)
    router = HttpRouter_register_slot(router, METHOD_GET, "/time", 2)
    router = HttpRouter_register_slot(router, METHOD_POST, "/echo", 3)
    router = HttpRouter_register_slot(router, METHOD_GET, "/", 4)
    serve_handlers(host, port, MAX_REQUESTS, router, HTTPServer_handler)
}
