extern fn hw_display_width() -> i32
extern fn hw_display_height() -> i32
extern fn hw_display_refresh_hz() -> i32
extern fn hw_display_brightness_pct() -> i32

fn display_width() -> i32 {
    return hw_display_width()
}

fn display_height() -> i32 {
    return hw_display_height()
}

fn display_refresh_hz() -> i32 {
    return hw_display_refresh_hz()
}

// 0–100, or -1 if unavailable (common on desktop without backlight sysfs).
fn display_brightness_percent() -> i32 {
    return hw_display_brightness_pct()
}
