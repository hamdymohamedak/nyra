extern fn gzip_file(src: string, dst: string) -> i32
extern fn gunzip_file(src: string, dst: string) -> i32

fn gzip_compress_file(src: string, dst: string) -> i32 {
    return gzip_file(src, dst)
}

fn gzip_decompress_file(src: string, dst: string) -> i32 {
    return gunzip_file(src, dst)
}
