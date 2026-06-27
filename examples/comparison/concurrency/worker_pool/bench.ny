allow_extended
extern fn channel_new() -> ptr
extern fn channel_send(ch: ptr, value: i32) -> void
extern fn channel_recv(ch: ptr) -> i32

extern fn blackbox_i32(x: i32) -> i32

fn main() {
    let mut acc = 0
    let jobs = channel_new()
    let results = channel_new()
    let workers = 4
    let total = 500000
    let mut w = 0
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
    let mut i = 0
    while i < total {
        channel_send(jobs, i)
        i = i + 1
    }
    let mut sent = 0
    while sent < workers {
        channel_send(jobs, -1)
        sent = sent + 1
    }
    let mut got = 0
    while got < total {
        acc = (acc + channel_recv(results)) % 1000000007
        got = got + 1
    }

    print(blackbox_i32(acc))
}
