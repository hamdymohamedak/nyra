import "@root/vendor/bindings/raylib.ny"
import "theme.ny"
import "font.ny"
import "render.ny"
import "keyboard.ny"
import "tabs.ny"
import "../terminal/scrollback.ny"

extern fn strlen(s: string) -> i32

fn GpuApp_apply_keys(app: GpuApp, keys, prev_line) -> GpuApp {
    if keys.tab_action == TAB_ACTION_NEW {
        return GpuApp_add_tab(app, "bash", TAB_KIND_SHELL)
    }
    if keys.tab_action == TAB_ACTION_PRIVATE {
        return GpuApp_add_tab(app, "private", TAB_KIND_PRIVATE)
    }
    if keys.tab_action == TAB_ACTION_CLOSE {
        return GpuApp_close_tab(app)
    }
    if keys.tab_action == TAB_ACTION_NEXT {
        return GpuApp_next_tab(app)
    }
    if keys.tab_action == TAB_ACTION_PREV {
        return GpuApp_prev_tab(app)
    }
    let pane = GpuApp_active_pane(app)
    let mut updated = pane
    if keys.submit == 1 && strlen(prev_line) > 0 {
        updated = GpuPane_append_cmd(pane, prev_line)
    }
    if keys.screen_clear == 1 {
        updated = GpuPane {
            title: updated.title
            kind: updated.kind
            shell: updated.shell
            scrollback: ScrollbackBuffer_clear(updated.scrollback)
            partial: ""
            input_line: keys.input_line
            fullscreen: updated.fullscreen
            used: updated.used
        }
    }
    updated = GpuPane {
        title: updated.title
        kind: updated.kind
        shell: updated.shell
        scrollback: updated.scrollback
        partial: updated.partial
        input_line: keys.input_line
        fullscreen: updated.fullscreen
        used: updated.used
    }
    return GpuApp_set_active_pane(app, updated)
}

fn GpuApp_draw_status(_app){
    DrawRectangle(0, WIN_H - STATUS_BAR_H, WIN_W, STATUS_BAR_H, GpuTheme_bg_panel())
    DrawLine(0, WIN_H - STATUS_BAR_H, WIN_W, WIN_H - STATUS_BAR_H, GpuTheme_fg_dim())
    if IsWindowFocused() == false {
        GpuFont_draw("click to type  ·  Ctrl+T tab  ·  Ctrl+Shift+T private  ·  Ctrl+Q quit", PAD_X, WIN_H - 17, 13, GpuTheme_fg_error())
        return
    }
    GpuFont_draw("Ctrl+T new  ·  Ctrl+Shift+T private  ·  Ctrl+W close  ·  Ctrl+PgUp/Dn switch  ·  Ctrl+Q quit", PAD_X, WIN_H - 17, 13, GpuTheme_fg_dim())
}

fn GpuApp_draw_pane(pane: GpuPane){
    let mut scroll_rows = GpuTerm_scroll_rows()
    if pane.fullscreen == 1 {
        scroll_rows = GpuTerm_visible_rows()
    }
    let start = ScrollbackBuffer_last_n(pane.scrollback, scroll_rows)
    let len = ScrollbackBuffer_len(pane.scrollback)
    let mut row = 0
    let mut i = start
    while i < len && row < scroll_rows {
        let line = ScrollbackBuffer_get(pane.scrollback, i)
        TermGrid_draw_line(row, line)
        row = row + 1
        i = i + 1
    }
    if pane.fullscreen == 1 {
        return
    }
    let input_row = GpuTerm_input_row()
    TermGrid_draw_prompt(input_row, pane.input_line)
    let cursor_grid = TermGrid {
        cols: GpuTerm_cols()
        rows: GpuTerm_visible_rows()
        cursor_row: input_row
        cursor_col: strlen(pane.input_line)
    }
    TermGrid_draw_cursor(cursor_grid, 1)
}

fn Gpu_run_window(max_frames: i32){
    InitWindow(WIN_W, WIN_H, "GhostTerm")
    SetExitKey(0)
    DisableEventWaiting()
    SetTargetFPS(60)
    GpuFont_init()
    let mut app = GpuApp_new(max_frames)
    let mut running = 1
    while WindowShouldClose() == false && running == 1 {
        if app.max_frames > 0 && app.frame >= app.max_frames {
            running = 0
        }
        let pane = GpuApp_active_pane(app)
        let prev_line = pane.input_line
        let keys = GpuKeyboard_poll(pane.shell, pane.input_line, pane.fullscreen)
        if keys.quit == 1 {
            running = 0
        }
        app = GpuApp_apply_keys(app, keys, prev_line)
        app = GpuApp_tick(app)
        let active = GpuApp_active_pane(app)
        BeginDrawing()
        ClearBackground(GpuTheme_bg_dark())
        GpuRender_draw_tab_bar(app.count, app.active, app.p0.title, app.p0.kind, app.p0.used, app.p1.title, app.p1.kind, app.p1.used, app.p2.title, app.p2.kind, app.p2.used, app.p3.title, app.p3.kind, app.p3.used)
        GpuApp_draw_pane(active)
        GpuApp_draw_status(app)
        EndDrawing()
    }
    GpuApp_close_all(app)
    GpuFont_unload()
    CloseWindow()
}

fn Gpu_run_demo(){
    print("\n--- GPU terminal ---", color: bold)
    Gpu_run_window(600)
}

fn Gpu_run_interactive(){
    Gpu_run_window(0)
}
