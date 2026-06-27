// Networking production maturity (v1.20.0) — typed smoke.

fn test_tls_validate_missing() -> i32 {
    let rc: i32 = tls_validate_pem("/nonexistent-cert.pem", "/nonexistent-key.pem")
    if rc == 0 {
        print("tls_validate should fail for missing files")
        return 1
    }
    let err: string = tls_last_error()
    if strlen(err) == 0 {
        print("tls_last_error should be set")
        return 1
    }
    print("tls validate missing ok")
    return 0
}

fn test_tls_prod_hint() -> i32 {
    let hint: string = tls_prod_hint()
    if strstr_pos(hint, "NYRA_TLS_CERT") < 0 {
        print("tls_prod_hint missing env name")
        return 1
    }
    print("tls prod hint ok")
    return 0
}

fn test_ping_icmp_capable() -> i32 {
    let cap: i32 = ping_icmp_capable()
    if cap == 1 {
        print("ping_icmp_capable: native ICMP available")
    } else if cap == 0 {
        print("ping_icmp_capable: system ping fallback")
    } else {
        print("ping_icmp_capable: unsupported platform")
    }
    return 0
}

fn main() -> i32 {
    if test_tls_validate_missing() != 0 { return 1 }
    if test_tls_prod_hint() != 0 { return 1 }
    if test_ping_icmp_capable() != 0 { return 1 }
    print("net prod typed ok")
    return 0
}
