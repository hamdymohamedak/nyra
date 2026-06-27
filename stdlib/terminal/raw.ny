extern fn stdin_set_raw_mode(enable: i32) -> void
extern fn stdin_read_key() -> i32

fn terminal_raw_on() {
    stdin_set_raw_mode(1)
}

fn terminal_raw_off() {
    stdin_set_raw_mode(0)
}

fn terminal_read_key() {
    return stdin_read_key()
}
