fn test_gzip_roundtrip() -> void {
    let raw = "nyra gzip roundtrip payload"
    let packed = gzip_compress(raw)
    let out = gzip_decompress(packed)
    assert_str_eq(out, raw)
}

fn main() -> i32 {
    test_gzip_roundtrip()
    return 0
}
