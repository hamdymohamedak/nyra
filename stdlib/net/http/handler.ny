import "types.ny"
import "response.ny"

fn Http_dispatch_slot(slot: i32, ctx: RequestContext, handler: fn(i32, RequestContext) -> HttpResponse) -> HttpResponse {
    if slot < 0 {
        return response_not_found()
    }
    return handler(slot, ctx)
}
