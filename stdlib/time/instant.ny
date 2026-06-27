extern fn instant_now() -> i64
extern fn instant_elapsed_ms(start: i64) -> i32
extern fn sleep_ms(ms: i32) -> void

struct Instant {
    start: i64
}

fn Instant_now() -> Instant {
    return Instant { start: instant_now() }
}

impl Instant {
    fn elapsed_ms(self) -> i32 {
        return instant_elapsed_ms(self.start)
    }
}

struct Duration {
    millis: i32
}

fn Duration_from_ms(ms: i32) -> Duration {
    return Duration { millis: ms }
}

fn sleep(ms: i32) -> void {
    sleep_ms(ms)
}

fn now_ms() -> i64 {
    return instant_now()
}
