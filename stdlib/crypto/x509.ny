extern fn x509_available() -> i32
extern fn x509_pem_subject(pem_cert: string) -> string
extern fn x509_pem_issuer(pem_cert: string) -> string
extern fn x509_pem_verify_time(pem_cert: string) -> i32

fn X509_ready() -> i32 {
    return x509_available()
}

fn x509_subject(pem_cert: string) -> string {
    return x509_pem_subject(pem_cert)
}

fn x509_issuer(pem_cert: string) -> string {
    return x509_pem_issuer(pem_cert)
}

fn x509_valid_now(pem_cert: string) -> i32 {
    return x509_pem_verify_time(pem_cert)
}
