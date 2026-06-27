import "../core/types.ny"

extern fn strlen(s: string) -> i32

fn ShellKind_default_binary(kind){
    return match kind {
        ShellKind.Bash => "/bin/bash"
        ShellKind.Zsh => "/bin/zsh"
        ShellKind.Fish => "/bin/fish"
        ShellKind.PowerShell => "/bin/zsh"
        ShellKind.Cmd => "/bin/bash"
        ShellKind.Nushell => "/bin/zsh"
        ShellKind.Wsl => "/bin/bash"
        ShellKind.Ssh => "/bin/bash"
        ShellKind.Custom => "/bin/bash"
    }
}

struct ShellSession {
    pty: PtySession
    shell_kind: ShellKind
    profile_id: i32
    identity_id: i32
}

fn ShellSession_empty(){
    return ShellSession {
        pty: PtySession {
            master_fd: -1
            rows: 0
            cols: 0
            alive: 0
        }
        shell_kind: ShellKind.Bash
        profile_id: 0
        identity_id: 0
    }
}

fn ShellSession_spawn(kind, profile_id, identity_id){
    let bin = ShellKind_default_binary(kind)
    let pty = PtySession_spawn(bin)
    return ShellSession {
        pty: pty
        shell_kind: kind
        profile_id: profile_id
        identity_id: identity_id
    }
}

fn ShellSession_prime(sess){
    PtySession_write(sess.pty, "stty -echo 2>/dev/null\n")
}

fn ShellSession_configure(sess){
    PtySession_write(sess.pty, "export BASH_SILENCE_DEPRECATION_WARNING=1\n")
    PtySession_write(sess.pty, "export PS1=''\n")
    PtySession_write(sess.pty, "export CLICOLOR=1\n")
    PtySession_write(sess.pty, "export LSCOLORS=GxFxcxdxBxegedabagaced\n")
    PtySession_write(sess.pty, "alias ls='ls -G'\n")
}

fn ShellSession_send_line(sess, line){
    PtySession_write(sess.pty, line)
    PtySession_write(sess.pty, "\n")
}

fn ShellSession_drain(sess){
    return PtySession_drain(sess.pty)
}

fn ShellSession_poll(sess){
    return PtySession_poll(sess.pty)
}

fn ShellSession_close(sess){
    let pty = PtySession_close(sess.pty)
    return ShellSession {
        pty: pty
        shell_kind: sess.shell_kind
        profile_id: sess.profile_id
        identity_id: sess.identity_id
    }
}
