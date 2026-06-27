// Networking stdlib gaps — zero-types smoke (DNS, ping, router, chunked body).

fn test_route_key() {
    let key = route_key(METHOD_GET, "/health")
    if strcmp(key, "GET:/health") != 0 {
        print("route_key failed")
        return 1
    }
    return 0
}

fn test_chunked_body() {
    let raw = "HTTP/1.1 200 OK\r\nTransfer-Encoding: chunked\r\n\r\n5\r\nhello\r\n0\r\n\r\n"
    let body = body_from_raw(raw)
    if strcmp(body, "hello") != 0 {
        print("chunked decode failed")
        return 1
    }
    return 0
}

fn test_dns_lookup() {
    let ips = dns_lookup("localhost")
    let n = ips.len()
    if n < 1 {
        print("dns_lookup localhost failed")
        return 1
    }
    print(strcat("dns ok: ", ips.get(0)))
    return 0
}

fn test_ping_tcp() {
    let ms = ping_tcp("127.0.0.1", 1, 500)
    if ms < 0 {
        print("ping_tcp closed port ok (unreachable)")
        return 0
    }
    print(strcat("ping ms=", i32_to_string(ms)))
    return 0
}

fn test_http_router() {
    let mut router = HttpRouter_new()
    router = HttpRouter_register(router, METHOD_GET, "/health", "health")
    let ctx = RequestContext_from_raw("GET /health HTTP/1.1\r\n\r\n")
    let tag = HttpRouter_lookup(router, ctx)
    if strcmp(tag, "health") != 0 {
        print("HttpRouter_lookup failed")
        return 1
    }
    return 0
}

fn main() {
    if test_route_key() != 0 { return 1 }
    if test_chunked_body() != 0 { return 1 }
    if test_http_router() != 0 { return 1 }
    if test_dns_lookup() != 0 { return 1 }
    if test_ping_tcp() != 0 { return 1 }
    print("net stdlib gaps ok")
    return 0
}
