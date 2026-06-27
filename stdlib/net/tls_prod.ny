// Production TLS workflow — real cert/key paths via env, verified client connections.
import "../tls.ny"
import "../fs.ny"
import "../env/mod.ny"

const TLS_ENV_CERT = "NYRA_TLS_CERT"
const TLS_ENV_KEY = "NYRA_TLS_KEY"
const TLS_ENV_CA = "NYRA_SSL_CA_FILE"

fn tls_prod_cert_path() -> string {
    return env_get(TLS_ENV_CERT)
}

fn tls_prod_key_path() -> string {
    return env_get(TLS_ENV_KEY)
}

fn tls_prod_ca_path() -> string {
    return env_get(TLS_ENV_CA)
}

fn tls_prod_ready() -> bool {
    if !tls_ready() {
        return false
    }
    let cert = tls_prod_cert_path()
    let key = tls_prod_key_path()
    if strlen(cert) == 0 || strlen(key) == 0 {
        return false
    }
    if file_exists(cert) != 1 || file_exists(key) != 1 {
        return false
    }
    return tls_validate_pem(cert, key) == 0
}

fn tls_prod_hint() -> string {
    return strcat(
        "set ",
        strcat(
            TLS_ENV_CERT,
            strcat(" and ", strcat(TLS_ENV_KEY, " to PEM file paths (optional NYRA_SSL_CA_FILE for custom CA)"))
        )
    )
}

fn tls_prod_require(feature: string) -> bool {
    if !tls_require(feature) {
        return false
    }
    if tls_prod_ready() {
        return true
    }
    print(strcat(strcat(feature, ": production TLS not configured — "), tls_prod_hint()))
    return false
}

fn tls_listen_prod(host: string, port: i32) -> i32 {
    if !tls_prod_require("tls_listen_prod") {
        return -1
    }
    return tls_listen(tls_prod_cert_path(), tls_prod_key_path(), host, port)
}

fn tls_connect_prod(host: string, port: i32) -> i32 {
    if !tls_require("tls_connect_prod") {
        return -1
    }
    let ca = tls_prod_ca_path()
    if strlen(ca) > 0 {
        return tls_connect_ca(host, port, ca)
    }
    return tls_connect_verify(host, port)
}

fn tls_upgrade_prod(plain_fd: i32, hostname: string) -> i32 {
    if !tls_require("tls_upgrade_prod") {
        return -1
    }
    let ca = tls_prod_ca_path()
    if strlen(ca) > 0 {
        return tls_upgrade_ca(plain_fd, hostname, ca)
    }
    return tls_upgrade_verify(plain_fd, hostname)
}
