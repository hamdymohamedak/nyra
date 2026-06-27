// Escape analysis: sequential channel → LocalChannel (stack ring buffer, no mutex).
// N ping-pong send/recv pairs in one thread.
extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32

fn main() {
    let ch = channel_new()
    let n = 500000
    let mod = 1000000007
    mut acc = 0
    mut i = 0
    while i < n {
        channel_send(ch, i)
        acc = (acc + channel_recv(ch)) % mod
        i = i + 1
    }
    print(acc)
}
