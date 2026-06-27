const API_PORT = 3000
const ITEMS_PATH = "/api/items"

struct ItemStore {
    db: HashMap_str_str
}

struct ApiResult {
    store: ItemStore
    resp: HttpResponse
}

fn ItemStore_new() {
    let mut db = HashMap_str_str_new()
    db = db.insert("__all__", "[]")
    db = db.insert("__next_id__", "1")
    return ItemStore { db: db }
}

fn ItemStore_next_id(store) {
    let n = store.db.get("__next_id__")
    if strlen(n) == 0 {
        return 1
    }
    return str_to_i32(n)
}

fn RestAPI_handle(ctx, store, router) {
    if strcmp(ctx.path, "/health") == 0 {
        return ApiResult { store: store, resp: response_ok_json("{\"ok\":true}") }
    }
    let tag = HttpRouter_lookup(router, ctx)
    if strcmp(tag, "items_get") == 0 {
        let id = ctx.query
        if strlen(id) == 0 {
            return ApiResult { store: store, resp: response_ok_json(store.db.get("__all__")) }
        }
        let key = strcat("item:", id)
        if store.db.contains(key) == 1 {
            let body = strcat("{\"id\":\"", strcat(id, strcat("\",\"data\":", strcat(store.db.get(key), "}"))))
            return ApiResult { store: store, resp: response_ok_json(body) }
        }
        return ApiResult { store: store, resp: response_not_found() }
    }
    if strcmp(tag, "items_post") == 0 {
        let id = ItemStore_next_id(store)
        let key = strcat("item:", i32_to_string(id))
        let mut db = store.db.insert(key, ctx.body)
        db = db.insert("__next_id__", i32_to_string(id + 1))
        let new_store = ItemStore { db: db }
        let body = strcat("{\"id\":", strcat(i32_to_string(id), ",\"created\":true}"))
        return ApiResult { store: new_store, resp: response_created_json(body) }
    }
    if strcmp(tag, "items_delete") == 0 {
        let id = ctx.query
        let key = strcat("item:", id)
        if store.db.contains(key) == 1 {
            let db = store.db.insert(key, "")
            return ApiResult { store: ItemStore { db: db }, resp: response_no_content() }
        }
        return ApiResult { store: store, resp: response_not_found() }
    }
    return ApiResult { store: store, resp: response_not_found() }
}

fn RestAPI_serve_connection(stream, store, router) {
    let mut out = store
    let mut hops = 0
    while hops < 6 {
        let raw = tcp_read(stream, 65536)
        if strlen(raw) == 0 {
            break
        }
        let ctx = RequestContext_from_raw(raw)
        let result = RestAPI_handle(ctx, out, router)
        out = result.store
        let ka = wants_keep_alive(raw)
        tcp_write(stream, build_response(result.resp, ka))
        if ka == 0 {
            break
        }
        hops = hops + 1
    }
    return out
}

fn RestAPI_run() {
    let mut store = ItemStore_new()
    let mut router = HttpRouter_new()
    router = HttpRouter_register(router, METHOD_GET, ITEMS_PATH, "items_get")
    router = HttpRouter_register(router, METHOD_POST, ITEMS_PATH, "items_post")
    router = HttpRouter_register(router, METHOD_DELETE, ITEMS_PATH, "items_delete")
    print(`REST API on http://127.0.0.1:${API_PORT}`)
    print("GET /api/items?id=1 · POST /api/items · DELETE /api/items?id=1")
    let listener = tcp_listen("127.0.0.1", API_PORT)
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
        store = RestAPI_serve_connection(stream, store, router)
        tcp_close_stream(stream)
        count = count + 1
    }
    tcp_close_listener(listener)
}
