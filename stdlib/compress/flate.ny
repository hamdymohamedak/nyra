extern fn flate_compress_hex(data: string) -> string
extern fn flate_decompress_hex(hex: string) -> string

fn flate_compress(data: string) -> string {
    return flate_compress_hex(data)
}

fn flate_decompress(hex: string) -> string {
    return flate_decompress_hex(hex)
}
