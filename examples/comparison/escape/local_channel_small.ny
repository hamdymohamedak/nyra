// Smoke test — same algorithm as local_channel.ny (N = 1000).
extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32

fn main() {
    let ch = channel_new()
    let n = 1000
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
