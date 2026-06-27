import "../net/http/response.ny"

fn http_response_ok(status: i32, body: string) -> string {
    let resp = response_text(status, body)
    return build_response(resp, 0)
}
