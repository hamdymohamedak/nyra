import "../strings.ny"

// bzip2 — requires `link bz2` in nyra.mod for native codec (stub returns input).
fn bzip2_compress(data: string) -> string {
    print("bzip2: native codec requires link bz2 in nyra.mod")
    return data
}

fn bzip2_decompress(data: string) -> string {
    print("bzip2: native codec requires link bz2 in nyra.mod")
    return data
}
