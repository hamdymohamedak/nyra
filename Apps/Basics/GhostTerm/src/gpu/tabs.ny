import "../terminal/scrollback.ny"
import "../terminal/io.ny"
import "../shell/spawn.ny"
import "ansi.ny"
import "theme.ny"

extern fn strlen(s: string) -> i32
extern fn strcmp(a: string, b: string) -> i32
extern fn strcat(a: string, b: string) -> string

const GPU_MAX_TABS = 4

struct GpuPane {
    title: string
    kind: i32
    shell: ShellSession
    scrollback: ScrollbackBuffer
    partial: string
    input_line: string
    fullscreen: i32
    used: i32
}

struct GpuApp {
    cols: i32
    rows: i32
    count: i32
    active: i32
    frame: i32
    max_frames: i32
    p0: GpuPane
    p1: GpuPane
    p2: GpuPane
    p3: GpuPane
}

fn GpuPane_empty(){
    return GpuPane {
        title: ""
        kind: TAB_KIND_SHELL
        shell: ShellSession_empty()
        scrollback: ScrollbackBuffer_new()
        partial: ""
        input_line: ""
        fullscreen: 0
        used: 0
    }
}

fn GpuPane_new(title, kind, cols, rows){
    let shell = ShellSession_spawn(ShellKind.Bash, 1, 1)
    PtySession_resize(shell.pty, rows, cols)
    ShellIo_bootstrap(shell)
    let mut scrollback = ScrollbackBuffer_new()
    scrollback = ScrollbackBuffer_append(scrollback, "GhostTerm — shell ready")
    return GpuPane {
        title: title
        kind: kind
        shell: shell
        scrollback: scrollback
        partial: ""
        input_line: ""
        fullscreen: 0
        used: 1
    }
}

fn GpuApp_new(max_frames: i32) -> GpuApp {
    let cols = GpuTerm_cols()
    let rows = GpuTerm_visible_rows()
    let first = GpuPane_new("bash", TAB_KIND_SHELL, cols, rows)
    return GpuApp {
        cols: cols
        rows: rows
        count: 1
        active: 0
        frame: 0
        max_frames: max_frames
        p0: first
        p1: GpuPane_empty()
        p2: GpuPane_empty()
        p3: GpuPane_empty()
    }
}

fn GpuApp_get_pane(app: GpuApp, idx) -> GpuPane {
    if idx == 0 {
        return app.p0
    }
    if idx == 1 {
        return app.p1
    }
    if idx == 2 {
        return app.p2
    }
    return app.p3
}

fn GpuApp_set_pane(app, idx, pane){
    if idx == 0 {
        return GpuApp {
            cols: app.cols
            rows: app.rows
            count: app.count
            active: app.active
            frame: app.frame
            max_frames: app.max_frames
            p0: pane
            p1: app.p1
            p2: app.p2
            p3: app.p3
        }
    }
    if idx == 1 {
        return GpuApp {
            cols: app.cols
            rows: app.rows
            count: app.count
            active: app.active
            frame: app.frame
            max_frames: app.max_frames
            p0: app.p0
            p1: pane
            p2: app.p2
            p3: app.p3
        }
    }
    if idx == 2 {
        return GpuApp {
            cols: app.cols
            rows: app.rows
            count: app.count
            active: app.active
            frame: app.frame
            max_frames: app.max_frames
            p0: app.p0
            p1: app.p1
            p2: pane
            p3: app.p3
        }
    }
    return GpuApp {
        cols: app.cols
        rows: app.rows
        count: app.count
        active: app.active
        frame: app.frame
        max_frames: app.max_frames
        p0: app.p0
        p1: app.p1
        p2: app.p2
        p3: pane
    }
}

fn GpuApp_active_pane(app: GpuApp) -> GpuPane {
    return GpuApp_get_pane(app, app.active)
}

fn GpuApp_set_active_pane(app, pane){
    return GpuApp_set_pane(app, app.active, pane)
}

fn GpuPane_is_clear_cmd(cmd){
    if strcmp(cmd, "clear") == 0 {
        return 1
    }
    if strcmp(cmd, "reset") == 0 {
        return 1
    }
    return 0
}

fn GpuPane_append_cmd(pane, cmd){
    if GpuPane_is_clear_cmd(cmd) == 1 {
        return GpuPane {
            title: pane.title
            kind: pane.kind
            shell: pane.shell
            scrollback: ScrollbackBuffer_clear(pane.scrollback)
            partial: ""
            input_line: pane.input_line
            fullscreen: pane.fullscreen
            used: pane.used
        }
    }
    if strlen(cmd) == 0 {
        return pane
    }
    let line = strcat("% ", cmd)
    let scrollback = ScrollbackBuffer_append(pane.scrollback, line)
    let mut fullscreen = pane.fullscreen
    if strcmp(cmd, "nano") == 0 {
        fullscreen = 1
    }
    return GpuPane {
        title: pane.title
        kind: pane.kind
        shell: pane.shell
        scrollback: scrollback
        partial: pane.partial
        input_line: pane.input_line
        fullscreen: fullscreen
        used: pane.used
    }
}

fn GpuPane_ingest(pane: GpuPane, chunk: string) -> GpuPane {
    if strlen(chunk) == 0 {
        return pane
    }
    let mut scrollback = pane.scrollback
    let mut partial = pane.partial
    let mut fullscreen = pane.fullscreen
    if Ansi_is_clear(chunk) == 1 {
        scrollback = ScrollbackBuffer_clear(scrollback)
        partial = ""
    }
    if Ansi_is_alt_on(chunk) == 1 {
        fullscreen = 1
    }
    if Ansi_is_alt_off(chunk) == 1 {
        fullscreen = 0
    }
    let feed = ScrollbackBuffer_feed(scrollback, partial, chunk)
    return GpuPane {
        title: pane.title
        kind: pane.kind
        shell: pane.shell
        scrollback: feed.buf
        partial: feed.partial
        input_line: pane.input_line
        fullscreen: fullscreen
        used: pane.used
    }
}

fn GpuPane_with_shell(pane, shell){
    return GpuPane {
        title: pane.title
        kind: pane.kind
        shell: shell
        scrollback: pane.scrollback
        partial: pane.partial
        input_line: pane.input_line
        fullscreen: pane.fullscreen
        used: pane.used
    }
}

fn GpuPane_poll(pane){
    if pane.shell.pty.alive == 0 {
        return pane
    }
    let mut current = pane
    let mut rounds = 0
    let mut idle_reads = 0
    while rounds < 32 {
        let chunk = PtySession_drain_raw(current.shell.pty)
        if strlen(chunk) > 0 {
            current = GpuPane_ingest(current, chunk)
            rounds = rounds + 1
            idle_reads = 0
        } else {
            if PtySession_poll(current.shell.pty) == 0 {
                idle_reads = idle_reads + 1
                if idle_reads >= 2 {
                    break
                }
            }
            let waited = PtySession_read_wait_raw(current.shell.pty, 16)
            if strlen(waited) == 0 {
                idle_reads = idle_reads + 1
                if idle_reads >= 2 {
                    break
                }
            } else {
                current = GpuPane_ingest(current, waited)
                rounds = rounds + 1
                idle_reads = 0
            }
        }
    }
    let shell = PtySession_reap(current.shell.pty)
    if shell.alive == 0 {
        return GpuPane_with_shell(current, ShellSession {
            pty: shell
            shell_kind: current.shell.shell_kind
            profile_id: current.shell.profile_id
            identity_id: current.shell.identity_id
        })
    }
    return current
}

fn GpuApp_tick(app: GpuApp) -> GpuApp {
    let pane = GpuPane_poll(GpuApp_active_pane(app))
    let updated = GpuApp_set_active_pane(app, pane)
    return GpuApp {
        cols: updated.cols
        rows: updated.rows
        count: updated.count
        active: updated.active
        frame: app.frame + 1
        max_frames: updated.max_frames
        p0: updated.p0
        p1: updated.p1
        p2: updated.p2
        p3: updated.p3
    }
}

fn GpuApp_add_tab(app, title, kind){
    if app.count >= GPU_MAX_TABS {
        return app
    }
    let pane = GpuPane_new(title, kind, app.cols, app.rows)
    let idx = app.count
    let updated = GpuApp_set_pane(app, idx, pane)
    return GpuApp {
        cols: updated.cols
        rows: updated.rows
        count: updated.count + 1
        active: idx
        frame: updated.frame
        max_frames: updated.max_frames
        p0: updated.p0
        p1: updated.p1
        p2: updated.p2
        p3: updated.p3
    }
}

fn GpuApp_close_tab(app){
    if app.count <= 1 {
        return app
    }
    let closing = GpuApp_active_pane(app)
    ShellSession_close(closing.shell)
    let mut next_active = app.active
    if next_active >= app.count - 1 {
        next_active = app.count - 2
    }
    let mut out = app
    let mut i = app.active
    while i < app.count - 1 {
        let src = GpuApp_get_pane(out, i + 1)
        out = GpuApp_set_pane(out, i, src)
        i = i + 1
    }
    let empty = GpuPane_empty()
    out = GpuApp_set_pane(out, app.count - 1, empty)
    return GpuApp {
        cols: out.cols
        rows: out.rows
        count: out.count - 1
        active: next_active
        frame: out.frame
        max_frames: out.max_frames
        p0: out.p0
        p1: out.p1
        p2: out.p2
        p3: out.p3
    }
}

fn GpuApp_next_tab(app){
    let mut next = app.active + 1
    if next >= app.count {
        next = 0
    }
    return GpuApp {
        cols: app.cols
        rows: app.rows
        count: app.count
        active: next
        frame: app.frame
        max_frames: app.max_frames
        p0: app.p0
        p1: app.p1
        p2: app.p2
        p3: app.p3
    }
}

fn GpuApp_prev_tab(app){
    let mut prev = app.active - 1
    if prev < 0 {
        prev = app.count - 1
    }
    return GpuApp {
        cols: app.cols
        rows: app.rows
        count: app.count
        active: prev
        frame: app.frame
        max_frames: app.max_frames
        p0: app.p0
        p1: app.p1
        p2: app.p2
        p3: app.p3
    }
}

fn GpuApp_close_all(app){
    let mut i = 0
    while i < app.count {
        let pane = GpuApp_get_pane(app, i)
        if pane.used == 1 {
            ShellSession_close(pane.shell)
        }
        i = i + 1
    }
}
