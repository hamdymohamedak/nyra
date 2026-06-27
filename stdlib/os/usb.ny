extern fn rt_usb_device_count() -> i32
extern fn rt_usb_device_vid(index: i32) -> i32
extern fn rt_usb_device_pid(index: i32) -> i32
extern fn rt_usb_device_path(index: i32) -> string

fn usb_device_count() -> i32 {
    return rt_usb_device_count()
}

fn usb_device_vid(index: i32) -> i32 {
    return rt_usb_device_vid(index)
}

fn usb_device_pid(index: i32) -> i32 {
    return rt_usb_device_pid(index)
}

fn usb_device_path(index: i32) -> string {
    return rt_usb_device_path(index)
}
