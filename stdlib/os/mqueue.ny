extern fn rt_mqueue_open(name: string, max_msgs: i32, msg_size: i32) -> i32
extern fn rt_mqueue_send(mq_id: i32, msg: string) -> i32
extern fn rt_mqueue_recv(mq_id: i32, max_bytes: i32) -> string
extern fn rt_mqueue_close(mq_id: i32) -> i32

// POSIX message queues (Linux). Name without leading slash.
fn mqueue_open(name: string, max_msgs: i32, msg_size: i32) -> i32 {
    return rt_mqueue_open(name, max_msgs, msg_size)
}

fn mqueue_send(mq_id: i32, msg: string) -> i32 {
    return rt_mqueue_send(mq_id, msg)
}

fn mqueue_recv(mq_id: i32, max_bytes: i32) -> string {
    return rt_mqueue_recv(mq_id, max_bytes)
}

fn mqueue_close(mq_id: i32) -> i32 {
    return rt_mqueue_close(mq_id)
}
