extern fn rt_signal_install(sig_num: i32) -> i32
extern fn rt_signal_poll(sig_num: i32) -> i32

const SIGINT = 2
const SIGTERM = 15
const SIGSEGV = 11
const SIGUSR1 = 10

// Install async-safe C handler; poll from your main loop (no Nyra callbacks in the handler).
fn signal_install(sig_num: i32) -> i32 {
    return rt_signal_install(sig_num)
}

fn signal_poll(sig_num: i32) -> bool {
    return rt_signal_poll(sig_num) == 1
}
