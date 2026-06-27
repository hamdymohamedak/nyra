fn main() -> i32 {
    let key = "01234567890123456789012345678901"
    let packed = aes_encrypt(key, "hello aes")
    print(aes_decrypt(key, packed))
    return 0
}
