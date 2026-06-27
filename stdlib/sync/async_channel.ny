import "channel.ny"

// AsyncChannel_i32 — promise + blocking channel bridge (Extended tier).
struct AsyncChannel_i32 {
    ch: Channel_i32
}

fn AsyncChannel_i32_new() -> AsyncChannel_i32 {
    return AsyncChannel_i32 { ch: Channel_i32_new() }
}

impl AsyncChannel_i32 {
    fn send(self, value: i32) -> AsyncChannel_i32 {
        let ch = self.ch.send(value)
        return AsyncChannel_i32 { ch: ch }
    }

    fn recv(self) -> i32 {
        return self.ch.recv()
    }
}

fn async_channel_send(ch: AsyncChannel_i32, value: i32) -> AsyncChannel_i32 {
    return ch.send(value)
}

fn async_channel_recv(ch: AsyncChannel_i32) -> i32 {
    return ch.recv()
}
