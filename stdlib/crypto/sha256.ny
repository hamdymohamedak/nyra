extern fn sha256_hex(data: string) -> string

fn sha256(data: string) -> string {
    return sha256_hex(data)
}
