struct BroadcastSession {
    targets: ptr
}

fn BroadcastSession_new(){
    return BroadcastSession { targets: Vec_str_new() }
}

fn BroadcastSession_add_target(sess, host){
    Vec_str_push(sess.targets, host)
    return sess
}

fn BroadcastSession_send(sess, command){
    let len = Vec_str_len(sess.targets)
    print(`broadcasting: ${command}`, color: bold)
    let mut i = 0
    while i < len {
        let host = Vec_str_get(sess.targets, i)
        print(`  → ${host}: ${command}`, color: green)
        i = i + 1
    }
}

fn BroadcastSession_demo(){
    let mut sess = BroadcastSession_new()
    sess = BroadcastSession_add_target(sess, "server-1.prod")
    sess = BroadcastSession_add_target(sess, "server-2.prod")
    sess = BroadcastSession_add_target(sess, "server-3.prod")
    BroadcastSession_send(sess, "sudo systemctl restart nginx")
}
