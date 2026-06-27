import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"
import "../../shared/widgets.ny"
import "stdlib/gui/buffer.ny"

const EDITOR_MAX = 4096

fn TextEditor_run(args) {
    let path = if args.len() == 1 { args.get(0) } else { "untitled.txt" }
    let mut buf = TextBuffer_new(EDITOR_MAX)
    if exists(path) == 1 && is_dir(path) == 0 {
        buf.text = read_file_limit(path, EDITOR_MAX)
        buf.cursor = strlen(buf.text)
    }
    let mut scroll = ScrollState_new(28)
    let bg = Gfx_color(30, 30, 34, 0xff)
    let area = Gfx_color(22, 22, 26, 0xff)
    let border = Gfx_color(80, 80, 90, 0xff)
    let ink = Gfx_color(230, 230, 235, 0xff)
    let hint = Gfx_color(120, 120, 130, 0xff)
    Gfx_window_open(900, 640, "Text Editor")
    while !WindowShouldClose() {
        let backspace = 0
        let left = 0
        let right = 0
        let up = 0
        let down = 0
        let mut bs = backspace
        let mut lk = left
        let mut rk = right
        let mut uk = up
        let mut dk = down
        if IsKeyPressed(259) {
            bs = 1
        }
        if IsKeyPressed(263) {
            lk = 1
        }
        if IsKeyPressed(262) {
            rk = 1
        }
        if IsKeyPressed(265) {
            uk = 1
        }
        if IsKeyPressed(264) {
            dk = 1
        }
        let mut ch = GetCharPressed()
        while ch > 0 {
            if ch == 8 {
                bs = 1
            } else {
                buf = TextBuffer_poll_keys(buf, bs, lk, rk, uk, dk, ch)
                bs = 0
                lk = 0
                rk = 0
                uk = 0
                dk = 0
            }
            ch = GetCharPressed()
        }
        buf = TextBuffer_poll_keys(buf, bs, lk, rk, uk, dk, 0)
        if IsKeyDown(341) && IsKeyPressed(83) {
            write_file(path, buf.text)
        }
        let packed = TextBuffer_line_col_at(buf.text, buf.cursor)
        let line = packed / 10000
        scroll = ScrollState_follow_line(scroll, line, StrVec_from_lines(buf.text).len())
        Gfx_frame_begin(bg)
        Gui_label(16, 12, strcat("file: ", path), 16, hint)
        Gui_label(16, 34, "Ctrl+S save | arrows move cursor | type to edit", 14, hint)
        Gui_text_area_draw_scrolled(16, 56, 868, 568, buf.text, scroll, area, border, ink)
        Gfx_frame_end()
    }
    Gfx_window_close()
    return 0
}
