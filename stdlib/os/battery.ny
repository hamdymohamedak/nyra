extern fn os_battery_percent() -> i32

// Returns 0-100, or -1 if no battery / unavailable on this platform.
fn battery_percent() -> i32 {
    return os_battery_percent()
}
