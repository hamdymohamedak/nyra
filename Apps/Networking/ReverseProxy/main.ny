import "src/proxy.ny"

fn main() {
    print("=== ReverseProxy — HTTP upstream ===", color: bold)
    ReverseProxy_run()
}
