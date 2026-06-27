// HTTP handler router + pool — explicit types.

fn demo_handler(slot: i32, ctx: RequestContext) -> HttpResponse {
    if slot == 1 {
        return response_ok_json("{\"slot\":1}")
    }
    if slot == 2 && ctx.method == METHOD_POST {
        return response_text(STATUS_OK, ctx.body)
    }
    return response_not_found()
}

fn main() -> void {
    let mut router = HttpRouter_new()
    router = HttpRouter_register_slot(router, METHOD_GET, "/api", 1)
    router = HttpRouter_register_slot(router, METHOD_POST, "/echo", 2)
    let ctx = RequestContext_from_raw("GET /api HTTP/1.1\r\n\r\n")
    let slot = HttpRouter_match_slot(router, ctx)
    let resp = Http_dispatch_slot(slot, ctx, demo_handler)
    print(strcat("handler status=", i32_to_string(resp.status)))
    let pool = HttpPool_new()
    let got = HttpPool_get(pool, "http://127.0.0.1:9/")
    print(strcat("pool status=", i32_to_string(got.resp.status)))
    print("net advanced example ok")
}
