// defer runs on return — nyra run examples/defer_return_smoke.ny

fn cleanup() -> void {
    print(1)
}

fn main() {
    defer cleanup()
    return
}
