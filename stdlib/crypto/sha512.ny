extern fn sha512_hex(data: string) -> string

fn sha512(data: string) -> string {
    return sha512_hex(data)
}
