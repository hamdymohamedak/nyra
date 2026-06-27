allow_extended
extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32

fn main() {
    let ch = channel_new()
    let n = 1000
    let mod = 1000000007
    spawn {
        mut i = 0
        while i < 1000 {
            channel_send(ch, i)
            i = i + 1
        }
    }
    mut acc = 0
    mut i = 0
    while i < n {
        acc = (acc + channel_recv(ch)) % mod
        i = i + 1
    }
    print(acc)
}
