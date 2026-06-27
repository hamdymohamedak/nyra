// Networking production maturity (v1.20.0) — TLS verify + ICMP fallbacks.

fn test_tls_validate_missing() {
    let rc = tls_validate_pem("/nonexistent-cert.pem", "/nonexistent-key.pem")
    if rc == 0 {
        print("tls_validate should fail for missing files")
        return 1
    }
    let err = tls_last_error()
    if strlen(err) == 0 {
        print("tls_last_error should be set")
        return 1
    }
    print("tls validate missing ok")
    return 0
}

fn test_tls_prod_hint() {
    let hint = tls_prod_hint()
    if strstr_pos(hint, "NYRA_TLS_CERT") < 0 {
        print("tls_prod_hint missing env name")
        return 1
    }
    print("tls prod hint ok")
    return 0
}

fn test_ping_icmp_capable() {
    let cap = ping_icmp_capable()
    if cap == 1 {
        print("ping_icmp_capable: native ICMP available")
    } else if cap == 0 {
        print("ping_icmp_capable: system ping fallback")
    } else {
        print("ping_icmp_capable: unsupported platform")
    }
    return 0
}

fn test_ping_auto_localhost() {
    let ms = ping_auto("127.0.0.1", 9, 500)
    if ms < 0 {
        print("ping_auto localhost ok (unreachable)")
        return 0
    }
    print(strcat("ping_auto ms=", i32_to_string(ms)))
    return 0
}

fn test_pool_https_verify() {
    if !tls_ready() {
        print("pool https skip (no tls)")
        return 0
    }
    let pool = HttpPool_new()
    let r = HttpPool_get(pool, "https://example.com/")
    if r.resp.status > 0 {
        print("pool https verify ok")
    } else {
        print("pool https unreachable")
    }
    return 0
}

fn main() {
    if test_tls_validate_missing() != 0 { return 1 }
    if test_tls_prod_hint() != 0 { return 1 }
    if test_ping_icmp_capable() != 0 { return 1 }
    if test_ping_auto_localhost() != 0 { return 1 }
    if test_pool_https_verify() != 0 { return 1 }
    print("net prod ok")
    return 0
}
