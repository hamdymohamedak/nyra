fn main() -> i32 {
    let raw = "compress me with gzip"
    let packed = gzip_compress(raw)
    print(gzip_decompress(packed))
    return 0
}
