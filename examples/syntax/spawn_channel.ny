allow_extended
fn main() {
    let ch = channel_new()
    spawn {
        channel_send(ch, 42)
    }
    print(channel_recv(ch))
}
