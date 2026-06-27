import "../time/instant.ny"

struct Context {
    cancelled: i32
    timeout_ms: i32
    start: Instant
}

fn Context_background() -> Context {
    return Context { cancelled: 0, timeout_ms: 0, start: Instant_now() }
}

fn Context_with_timeout(parent: Context, ms: i32) -> Context {
    return Context {
        cancelled: parent.cancelled,
        timeout_ms: ms,
        start: Instant_now(),
    }
}

fn Context_with_cancel(parent: Context) -> Context {
    return Context {
        cancelled: parent.cancelled,
        timeout_ms: parent.timeout_ms,
        start: parent.start,
    }
}

fn context_cancel(ctx: Context) -> Context {
    return Context { cancelled: 1, timeout_ms: ctx.timeout_ms, start: ctx.start }
}

fn context_done(ctx: Context) -> i32 {
    if ctx.cancelled != 0 {
        return 1
    }
    if ctx.timeout_ms > 0 {
        let elapsed = ctx.start.elapsed_ms()
        if elapsed >= ctx.timeout_ms {
            return 1
        }
    }
    return 0
}

fn context_wait_deadline(ctx: Context) -> i32 {
    if ctx.timeout_ms <= 0 {
        return 0
    }
    while context_done(ctx) == 0 {
        sleep(10)
    }
    return 1
}

fn context_sleep_or_done(ctx: Context, ms: i32) -> i32 {
    if context_done(ctx) != 0 {
        return 1
    }
    sleep(ms)
    return context_done(ctx)
}
