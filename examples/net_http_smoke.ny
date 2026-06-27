import "sonic/net/http/router.ny"
import "sonic/net/http/server.ny"
import "stdlib/net/http/response.ny"

fn main() {
    let router = Router_new()
    let r = Router_add_slot_get(router, "/health", 0)
    listen_and_serve_handlers("127.0.0.1", 8080, r, (_slot: i32, _ctx: RequestContext) => response_ok_json("{\"status\":\"ok\"}"))
}
