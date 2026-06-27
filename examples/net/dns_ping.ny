// DNS + TCP ping + HttpRouter (zero-types). Run: nyra run examples/net/dns_ping.ny

fn main() {
    let ips = dns_lookup("localhost")
    print(strcat("addresses: ", i32_to_string(ips.len())))
    let mut i = 0
    while i < ips.len() {
        print(ips.get(i))
        i = i + 1
    }
    let ms = ping_tcp("127.0.0.1", 1, 300)
    print(strcat("closed-port probe ms=", i32_to_string(ms)))
    let mut router = HttpRouter_new()
    router = HttpRouter_register(router, METHOD_GET, "/health", "health")
    let ctx = RequestContext_from_raw("GET /health HTTP/1.1\r\n\r\n")
    print(HttpRouter_lookup(router, ctx))
}
