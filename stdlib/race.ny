// Native Nyra race detector (lightweight lock-set; use `--race-native` or TSan `--race`).

extern fn race_runtime_init() -> void
extern fn race_track_read(addr: ptr, nbytes: i32) -> void
extern fn race_track_write(addr: ptr, nbytes: i32) -> void
extern fn race_clear_access(addr: ptr) -> void
extern fn race_runtime_enabled() -> i32

fn Race_init() -> void {
    race_runtime_init()
}

fn Race_track_read(addr: ptr, nbytes: i32) -> void {
    race_track_read(addr, nbytes)
}

fn Race_track_write(addr: ptr, nbytes: i32) -> void {
    race_track_write(addr, nbytes)
}

fn Race_clear(addr: ptr) -> void {
    race_clear_access(addr)
}

fn Race_enabled() -> i32 {
    return race_runtime_enabled()
}
