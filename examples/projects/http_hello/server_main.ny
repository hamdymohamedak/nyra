import "../../../stdlib/http/server.ny"

fn main() {
    let ok = http_serve_once("127.0.0.1", 18080, "Hello from Nyra HTTP\n")
    print(ok)
}
