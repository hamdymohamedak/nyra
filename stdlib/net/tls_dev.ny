import "../tls.ny"
import "../fs.ny"

const TLS_DEV_CERT = "/tmp/nyra-dev.pem"
const TLS_DEV_KEY = "/tmp/nyra-dev-key.pem"

extern fn rt_tls_gen_self_signed(cert_path: string, key_path: string, common_name: string) -> i32

fn tls_dev_cert_path() -> string {
    return TLS_DEV_CERT
}

fn tls_dev_key_path() -> string {
    return TLS_DEV_KEY
}

fn tls_dev_ensure(common_name: string) -> i32 {
    if file_exists(TLS_DEV_CERT) == 1 && file_exists(TLS_DEV_KEY) == 1 {
        return 0
    }
    if !tls_ready() {
        print("tls_dev: OpenSSL required (brew install openssl / apt install libssl-dev)")
        return -1
    }
    let rc = rt_tls_gen_self_signed(TLS_DEV_CERT, TLS_DEV_KEY, common_name)
    if rc != 0 {
        print("tls_dev: failed to write dev certificate files")
    }
    return rc
}

fn tls_listen_dev(host: string, port: i32) -> i32 {
    if tls_dev_ensure(host) != 0 {
        return -1
    }
    return tls_listen(TLS_DEV_CERT, TLS_DEV_KEY, host, port)
}
