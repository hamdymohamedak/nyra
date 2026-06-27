extern fn rt_serial_open(path: string, baud: i32) -> i32
extern fn rt_serial_read(handle: i32, max_bytes: i32) -> string
extern fn rt_serial_write(handle: i32, data: string) -> i32
extern fn rt_serial_close(handle: i32) -> i32

// Opens a serial device (e.g. /dev/ttyUSB0, COM3). Returns handle or -1.
fn serial_open(path: string, baud: i32) -> i32 {
    return rt_serial_open(path, baud)
}

fn serial_read(handle: i32, max_bytes: i32) -> string {
    return rt_serial_read(handle, max_bytes)
}

fn serial_write(handle: i32, data: string) -> i32 {
    return rt_serial_write(handle, data)
}

fn serial_close(handle: i32) -> i32 {
    return rt_serial_close(handle)
}
