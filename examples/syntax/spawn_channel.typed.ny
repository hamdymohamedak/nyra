allow_extended
fn main() -> void {
    let ch = channel_new()
    spawn {
        channel_send(ch, 42)
    }
    print(channel_recv(ch))
}
