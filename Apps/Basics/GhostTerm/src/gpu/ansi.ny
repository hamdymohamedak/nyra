import "@root/vendor/bindings/raylib.ny"
import "theme.ny"
import "font.ny"

extern fn strlen(s: string) -> i32
extern fn strstr_pos(hay: string, needle: string) -> i32
extern fn substring(s: string, start: i32, len: i32) -> string

fn Ansi_is_clear(text){
    if strstr_pos(text, "[2J") >= 0 {
        return 1
    }
    if strstr_pos(text, "[3J") >= 0 {
        return 1
    }
    if strstr_pos(text, "[H\x1b[2J") >= 0 {
        return 1
    }
    return 0
}

fn Ansi_is_alt_on(text){
    if strstr_pos(text, "[?1049h") >= 0 {
        return 1
    }
    if strstr_pos(text, "[1049h") >= 0 {
        return 1
    }
    return 0
}

fn Ansi_is_alt_off(text){
    if strstr_pos(text, "[?1049l") >= 0 {
        return 1
    }
    if strstr_pos(text, "[1049l") >= 0 {
        return 1
    }
    return 0
}

fn Ansi_color_from_code(code){
    if strstr_pos(code, "31") >= 0 {
        return GpuTheme_fg_error()
    }
    if strstr_pos(code, "32") >= 0 {
        return GpuTheme_fg_exec()
    }
    if strstr_pos(code, "33") >= 0 {
        return GpuTheme_fg_warn()
    }
    if strstr_pos(code, "34") >= 0 {
        return GpuTheme_fg_dir()
    }
    if strstr_pos(code, "35") >= 0 {
        return GpuTheme_fg_private()
    }
    if strstr_pos(code, "36") >= 0 {
        return GpuTheme_fg_link()
    }
    if strstr_pos(code, "90") >= 0 {
        return GpuTheme_fg_dim()
    }
    return GpuTheme_fg_default()
}

fn Ansi_draw_text(x, y, text, color){
    if strlen(text) == 0 {
        return x
    }
    GpuFont_draw(text, x, y, FONT_SIZE, color)
    return x + strlen(text) * CELL_W
}

fn Ansi_draw_line(row, text, default_color){
    let y = GpuTerm_row_y(row)
    if strstr_pos(text, "\x1b[") < 0 {
        GpuFont_draw(text, PAD_X, y, FONT_SIZE, default_color)
        return
    }
    let mut x = PAD_X
    let mut color = default_color
    let mut rest = text
    while strlen(rest) > 0 {
        let esc = strstr_pos(rest, "\x1b[")
        if esc < 0 {
            x = Ansi_draw_text(x, y, rest, color)
            break
        }
        if esc > 0 {
            let plain = substring(rest, 0, esc)
            x = Ansi_draw_text(x, y, plain, color)
            rest = substring(rest, esc, strlen(rest) - esc)
        }
        let end = strstr_pos(rest, "m")
        if end < 0 {
            x = Ansi_draw_text(x, y, rest, color)
            break
        }
        let code = substring(rest, 0, end + 1)
        color = Ansi_color_from_code(code)
        rest = substring(rest, end + 1, strlen(rest) - end - 1)
    }
}

fn GpuRender_color_for_line(line){
    if line.contains("error") == 1 || line.contains("Error") == 1 || line.contains("command not found") == 1 {
        return GpuTheme_fg_error()
    }
    return GpuTheme_fg_default()
}
