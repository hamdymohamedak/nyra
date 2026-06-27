extern fn hmac_sha256_hex(key: string, data: string) -> string

fn hmac_sha256(key: string, data: string) -> string {
    return hmac_sha256_hex(key, data)
}
