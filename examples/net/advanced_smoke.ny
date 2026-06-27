// Advanced networking — zero types (router slots + pool; handler fn needs typed example).

fn main() {
    let mut router = HttpRouter_new()
    router = HttpRouter_register_slot(router, METHOD_GET, "/api", 1)
    router = HttpRouter_register_slot(router, METHOD_POST, "/echo", 2)
    let ctx = RequestContext_from_raw("GET /api HTTP/1.1\r\n\r\n")
    let slot = HttpRouter_match_slot(router, ctx)
    if slot != 1 {
        print("slot match failed")
        return
    }
    let pool = HttpPool_new()
    let got = HttpPool_get(pool, "http://127.0.0.1:9/")
    print(strcat("pool status=", i32_to_string(got.resp.status)))
    let icmp = ping_icmp("127.0.0.1", 200)
    if icmp == -2 {
        print("icmp needs root")
    }
    print("net advanced example ok")
}
