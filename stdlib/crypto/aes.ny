extern fn aes_cbc_encrypt_hex(key: string, plaintext: string) -> string
extern fn aes_cbc_decrypt_hex(key: string, ciphertext_hex: string) -> string

fn aes_encrypt(key: string, plaintext: string) -> string {
    return aes_cbc_encrypt_hex(key, plaintext)
}

fn aes_decrypt(key: string, ciphertext: string) -> string {
    return aes_cbc_decrypt_hex(key, ciphertext)
}
