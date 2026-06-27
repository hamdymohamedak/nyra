fn test_sha512_empty() -> void {
    let digest = sha512("")
    assert_str_eq(digest, "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e")
}

fn test_sha512_abc() -> void {
    let digest = sha512("abc")
    assert_str_eq(digest, "ddaf35a193617abacc417349ae20413112e6fa4e89a97ea20a9eeee64b55d39a2192992a274fc1a836ba3c23a3feebbd454d4423643ce80e2a9ac94fa54ca49f")
}

fn test_hmac_sha256() -> void {
    let mac = hmac_sha256("key", "data")
    assert_str_eq(mac, "5031fe3d989c6d1537a013fa6e739da23463fdaec3b70137d828e36ace221bd0")
}

fn test_aes_roundtrip() -> void {
    let key = "01234567890123456789012345678901"
    let plain = "nyra aes portable c"
    let enc = aes_encrypt(key, plain)
    let dec = aes_decrypt(key, enc)
    assert_str_eq(dec, plain)
}

fn main() -> i32 {
    test_sha512_empty()
    test_sha512_abc()
    test_hmac_sha256()
    test_aes_roundtrip()
    return 0
}
