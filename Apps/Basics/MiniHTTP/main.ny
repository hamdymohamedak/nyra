import "src/server.ny"

fn main() {
    print("=== MiniHTTP — HTTP/1.1 server ===", color: bold)
    MiniHTTP_run()
}
