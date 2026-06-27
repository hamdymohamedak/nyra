import "../net/http/server.ny"

fn http_serve_once(host: string, port: i32, body: string) -> i32 {
    return serve_once(host, port, body)
}
