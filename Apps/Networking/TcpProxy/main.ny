import "src/proxy.ny"

fn main() {
    print("=== TcpProxy — TCP forwarder ===", color: bold)
    TcpProxy_run()
}
