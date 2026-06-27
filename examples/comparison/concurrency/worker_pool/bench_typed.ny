allow_extended
extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() -> void {
    let mut acc: i32 = 0
    let jobs = channel_new()
    let results = channel_new()
    let workers: i32 = 4
    let total: i32 = 500000
    let mut w: i32 = 0
    while w < workers {
        spawn {
            while true {
                let job = channel_recv(jobs)
                if job < 0 {
                    break
                }
                channel_send(results, (job * 31) % 997)
            }
        }
        w = w + 1
    }
    let mut i: i32 = 0
    while i < total {
        channel_send(jobs, i)
        i = i + 1
    }
    let mut sent: i32 = 0
    while sent < workers {
        channel_send(jobs, -1)
        sent = sent + 1
    }
    let mut got: i32 = 0
    while got < total {
        acc = (acc + channel_recv(results)) % 1000000007
        got = got + 1
    }

    print(blackbox_i32(acc))
}
