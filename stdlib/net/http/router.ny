import "../../strings.ny"
import "request.ny"

struct HttpRouter {
    routes: HashMap_str_str
    slots: HashMap_str_i32
}

fn HttpRouter_new() -> HttpRouter {
    return HttpRouter {
        routes: HashMap_str_str_new(),
        slots: HashMap_str_i32_new(),
    }
}

fn HttpRouter_register(router: HttpRouter, method: i32, path: string, tag: string) -> HttpRouter {
    let key = route_key(method, path)
    let routes = router.routes.insert(key, tag)
    return HttpRouter { routes: routes, slots: router.slots }
}

fn HttpRouter_register_slot(router: HttpRouter, method: i32, path: string, slot: i32) -> HttpRouter {
    let key = route_key(method, path)
    let slots = router.slots.insert(key, slot)
    return HttpRouter { routes: router.routes, slots: slots }
}

fn HttpRouter_lookup(router: HttpRouter, ctx: RequestContext) -> string {
    let key = route_key(ctx.method, ctx.path)
    if router.routes.contains(key) == 0 {
        return ""
    }
    return router.routes.get(key)
}

fn HttpRouter_match_slot(router: HttpRouter, ctx: RequestContext) -> i32 {
    let key = route_key(ctx.method, ctx.path)
    if router.slots.contains(key) == 0 {
        return -1
    }
    return router.slots.get(key)
}

fn HttpRouter_has(router: HttpRouter, method: i32, path: string) -> i32 {
    let key = route_key(method, path)
    if router.routes.contains(key) == 1 {
        return 1
    }
    return router.slots.contains(key)
}
