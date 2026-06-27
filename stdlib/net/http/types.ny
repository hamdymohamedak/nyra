// net/http — core types and HTTP constants (Go net/http inspired).

const METHOD_GET = 1
const METHOD_POST = 2
const METHOD_PUT = 3
const METHOD_DELETE = 4
const METHOD_OPTIONS = 5
const METHOD_HEAD = 6
const METHOD_PATCH = 7

const STATUS_OK = 200
const STATUS_CREATED = 201
const STATUS_NO_CONTENT = 204
const STATUS_BAD_REQUEST = 400
const STATUS_UNAUTHORIZED = 401
const STATUS_NOT_FOUND = 404
const STATUS_METHOD_NOT_ALLOWED = 405
const STATUS_UNPROCESSABLE = 422
const STATUS_TOO_MANY_REQUESTS = 429
const STATUS_INTERNAL_ERROR = 500

struct HttpRequest {
    method: i32
    url: string
    body: string
    content_type: string
}

struct HttpResponse {
    status: i32
    body: string
    content_type: string
}

struct RequestContext {
    method: i32
    path: string
    body: string
    query: string
    raw: string
}

struct Server {
    host: string
    port: i32
    router: ptr
    cors: i32
    keep_alive: i32
}

struct Client {
    user_agent: string
    timeout_ms: i32
}

fn Client_default() -> Client {
    return Client { user_agent: "Nyra/1.0", timeout_ms: 30000 }
}

fn HttpRequest_new(method: i32, url: string, body: string) -> HttpRequest {
    return HttpRequest { method: method, url: url, body: body, content_type: "application/json" }
}

fn HttpResponse_ok(body: string) -> HttpResponse {
    return HttpResponse { status: STATUS_OK, body: body, content_type: "application/json" }
}

fn HttpResponse_with_status(resp: HttpResponse, status: i32) -> HttpResponse {
    return HttpResponse { status: status, body: resp.body, content_type: resp.content_type }
}

fn HttpResponse_with_content_type(resp: HttpResponse, content_type: string) -> HttpResponse {
    return HttpResponse { status: resp.status, body: resp.body, content_type: content_type }
}
