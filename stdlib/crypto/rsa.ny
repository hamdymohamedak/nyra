extern fn rsa_available() -> i32
extern fn rsa_public_encrypt_pem(pem_pub: string, plaintext: string) -> string
extern fn rsa_sha256_sign_pem(pem_priv: string, message: string) -> string

fn Rsa_ready() -> i32 {
    return rsa_available()
}

fn rsa_encrypt_pem(pem_pub: string, plaintext: string) -> string {
    return rsa_public_encrypt_pem(pem_pub, plaintext)
}

fn rsa_sign_sha256_pem(pem_priv: string, message: string) -> string {
    return rsa_sha256_sign_pem(pem_priv, message)
}
