allow_extended
extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let ch = channel_new()
    spawn {
        let mut j = 0
        while j < 500000 {
            channel_send(ch, j)
            j = j + 1
        }
    }
    let mut i = 0
    while i < 500000 {
        acc = (acc + channel_recv(ch)) % 1000000007
        i = i + 1
    }

    print(blackbox_i32(acc))
}
