import "src/server.ny"

fn main() {
    print("=== HTTPServer — HTTP/1.1 ===", color: bold)
    HTTPServer_run()
}
