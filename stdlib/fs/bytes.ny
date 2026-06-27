struct Bytes {
    handle: ptr
}

extern fn bytes_read_file(path: string) -> ptr
extern fn bytes_len(handle: ptr) -> i64
extern fn byte_at(handle: ptr, index: i64) -> i32
extern fn bytes_write_file(path: string, handle: ptr) -> i32
extern fn bytes_from_string(s: string) -> ptr
extern fn bytes_to_string(handle: ptr) -> string
extern fn bytes_free(handle: ptr) -> void
extern fn stdin_read_bytes(max_bytes: i32) -> ptr
extern fn stdout_write_bytes(handle: ptr) -> void

fn Bytes_read(path: string) -> Bytes {
    return Bytes { handle: bytes_read_file(path) }
}

fn Bytes_write(path: string, data: Bytes) -> i32 {
    return bytes_write_file(path, data.handle)
}

fn Bytes_len(data: Bytes) -> i64 {
    return bytes_len(data.handle)
}

fn Bytes_to_string(data: Bytes) -> string {
    return bytes_to_string(data.handle)
}

fn Bytes_free(data: Bytes) -> void {
    bytes_free(data.handle)
}
