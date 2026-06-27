import "@root/vendor/bindings/raylib.ny"
import "theme.ny"
import "font.ny"
import "ansi.ny"

extern fn strlen(s: string) -> i32

struct TermGrid {
    cols: i32
    rows: i32
    cursor_row: i32
    cursor_col: i32
}

fn TermGrid_new(cols, rows){
    return TermGrid {
        cols: cols
        rows: rows
        cursor_row: 0
        cursor_col: 0
    }
}

fn TermGrid_draw_line(row, text){
    Ansi_draw_line(row, text, GpuRender_color_for_line(text))
}

fn TermGrid_draw_prompt(row, input){
    let y = GpuTerm_row_y(row)
    GpuFont_draw("% ", PAD_X, y, FONT_SIZE, GpuTheme_fg_prompt())
    GpuFont_draw(input, PAD_X + PROMPT_W, y, FONT_SIZE, GpuTheme_fg_default())
}

fn TermGrid_draw_cursor(grid, blink_on){
    if blink_on == 0 {
        return
    }
    let x = PAD_X + PROMPT_W + grid.cursor_col * CELL_W
    let y = GpuTerm_row_y(grid.cursor_row)
    DrawRectangle(x, y + 2, CELL_W - 1, CELL_H - 4, GpuTheme_cursor())
}

fn GpuRender_tab_label(kind, title){
    if kind == TAB_KIND_PRIVATE {
        return "private"
    }
    if kind == TAB_KIND_SANDBOX {
        return "sandbox"
    }
    return title
}

fn GpuRender_draw_one_tab(x, idx, active_idx, kind, title){
    let w = 110
    let mut bg = GpuTheme_bg_tab()
    let mut accent = GpuTheme_accent()
    if idx == active_idx {
        bg = GpuTheme_bg_tab_active()
    }
    if kind == TAB_KIND_PRIVATE {
        accent = GpuTheme_accent_private()
    }
    if kind == TAB_KIND_SANDBOX {
        accent = GpuTheme_fg_warn()
    }
    DrawRectangle(x, 6, w, TAB_BAR_H - 10, bg)
    if idx == active_idx {
        DrawRectangle(x, 6, w, 3, accent)
    }
    let label = GpuRender_tab_label(kind, title)
    GpuFont_draw(label, x + 10, 14, 14, GpuTheme_fg_default())
    return x + w + 6
}

fn GpuRender_draw_tab_bar(count, active, t0, k0, u0, t1, k1, u1, t2, k2, u2, t3, k3, u3){
    DrawRectangle(0, 0, WIN_W, TAB_BAR_H, GpuTheme_bg_panel())
    let mut x = PAD_X
    if count > 0 && u0 == 1 {
        x = GpuRender_draw_one_tab(x, 0, active, k0, t0)
    }
    if count > 1 && u1 == 1 {
        x = GpuRender_draw_one_tab(x, 1, active, k1, t1)
    }
    if count > 2 && u2 == 1 {
        x = GpuRender_draw_one_tab(x, 2, active, k2, t2)
    }
    if count > 3 && u3 == 1 {
        x = GpuRender_draw_one_tab(x, 3, active, k3, t3)
    }
    DrawLine(0, TAB_BAR_H - 1, WIN_W, TAB_BAR_H - 1, GpuTheme_fg_dim())
}
