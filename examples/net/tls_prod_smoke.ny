// Production TLS workflow — set NYRA_TLS_CERT + NYRA_TLS_KEY for wss:// / HTTPS servers.
// Client HTTPS uses system CA verification by default (optional NYRA_SSL_CA_FILE).

fn main() {
    print("TLS production workflow (v1.20.0)")
    print(strcat("hint: ", tls_prod_hint()))
    print(strcat("icmp capable: ", i32_to_string(ping_icmp_capable())))
    if tls_ready() {
        print(strcat("tls last error sample: ", tls_last_error()))
    }
    print("tls prod smoke ok")
}
