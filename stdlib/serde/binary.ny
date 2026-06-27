// Nyra binary format (NBF v1) — length-prefixed little-endian fields.

extern fn bin_buf_new() -> ptr
extern fn bin_buf_write_i32(buf: ptr, value: i32)
extern fn bin_buf_write_bool(buf: ptr, value: i32)
extern fn bin_buf_write_string(buf: ptr, value: string)
extern fn bin_buf_write_bytes(buf: ptr, data: ptr, len: i32)
extern fn bin_buf_finish(buf: ptr) -> ptr
extern fn bin_blob_payload_len(blob: ptr) -> i32
extern fn bin_decode_i32_at(blob: ptr, off: i32) -> i32
extern fn bin_decode_bool_at(blob: ptr, off: i32) -> i32
extern fn bin_decode_string_at(blob: ptr, off: i32) -> string
extern fn bin_field_width_string_at(blob: ptr, off: i32) -> i32
extern fn bin_field_width_i32() -> i32
extern fn bin_field_width_bool() -> i32
extern fn bin_field_width_bytes_at(blob: ptr, off: i32) -> i32
extern fn bin_blob_free(blob: ptr)

fn encode_i32(buf: ptr, value: i32) {
    bin_buf_write_i32(buf, value)
}

fn encode_bool(buf: ptr, value: i32) {
    bin_buf_write_bool(buf, value)
}

fn encode_string(buf: ptr, value: string) {
    bin_buf_write_string(buf, value)
}

extern fn bin_buf_append_blob(buf: ptr, blob: ptr)
extern fn bin_decode_blob_at(blob: ptr, off: i32) -> ptr
extern fn bin_field_width_blob_at(blob: ptr, off: i32) -> i32
