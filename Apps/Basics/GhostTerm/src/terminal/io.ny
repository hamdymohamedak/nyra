import "../shell/spawn.ny"

extern fn strlen(s: string) -> i32

fn ShellIo_discard(sess, timeout_ms){
    let mut quiet_ms = 0
    let mut elapsed = 0
    while elapsed < timeout_ms {
        let chunk = PtySession_drain(sess.pty)
        if strlen(chunk) > 0 {
            quiet_ms = 0
        } else {
            let _ = PtySession_read_wait(sess.pty, 50)
            quiet_ms = quiet_ms + 50
            if quiet_ms >= 500 {
                break
            }
        }
        elapsed = elapsed + 50
    }
}

fn ShellIo_drain_print(sess){
    PtySession_flush(sess.pty, 0)
}

fn ShellIo_drain_wait(sess, timeout_ms){
    PtySession_flush(sess.pty, timeout_ms)
}

fn ShellIo_bootstrap(sess){
    ShellSession_prime(sess)
    ShellIo_discard(sess, 2000)
    ShellSession_configure(sess)
    ShellIo_discard(sess, 2000)
}

fn ShellIo_welcome(){
    print("──────────────────────────────────────────────────", color: dim)
    print("  shell · type commands below  ·  help  ·  quit", color: dim)
    print("──────────────────────────────────────────────────\n", color: dim)
}

fn ShellIo_prompt(){
    print("ghostterm ", color: "#6B7280")
    print("❯ ", color: "#22D3EE")
}

fn ShellIo_read_line(){
    ShellIo_prompt()
    return input("")
}

fn ShellIo_exec(sess, line){
    ShellSession_send_line(sess, line)
    ShellIo_drain_wait(sess, 2500)
}
