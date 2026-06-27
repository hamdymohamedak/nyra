fn Gui_point_in_rect(px, py, x, y, w, h) {
    if px < x || py < y {
        return 0
    }
    if px >= x + w || py >= y + h {
        return 0
    }
    return 1
}

fn Gui_button_draw(x, y, w, h, label, bg, border, fg) {
    DrawRectangle(x, y, w, h, bg)
    DrawRectangleLines(x, y, w, h, border)
    let tw = MeasureText(label, 18)
    let tx = x + (w - tw) / 2
    let ty = y + (h - 18) / 2
    DrawText(label, tx, ty, 18, fg)
}

fn Gui_button_clicked(x: i32, y: i32, w: i32, h: i32) -> i32 {
    if !IsMouseButtonPressed(0) {
        return 0
    }
    let mx = GetMouseX()
    let my = GetMouseY()
    return Gui_point_in_rect(mx, my, x, y, w, h)
}

fn Gui_panel(x, y, w, h, fill, border) {
    DrawRectangle(x, y, w, h, fill)
    DrawRectangleLines(x, y, w, h, border)
}

fn Gui_label(x, y, text, size, color) {
    DrawText(text, x, y, size, color)
}

fn Gui_text_poll(text, max_len) {
    let mut out = text
    if IsKeyPressed(259) {
        out = str_pop(out)
    }
    let c = GetCharPressed()
    let mut ch = c
    while ch > 0 {
        if ch == 8 {
            out = str_pop(out)
        } else {
            if strlen(out) < max_len {
                out = str_push_char(out, ch)
            }
        }
        ch = GetCharPressed()
    }
    return out
}

fn Gui_text_area_draw(x, y, w, h, text, bg, border, fg) {
    let scroll = ScrollState_new((h - 16) / 18)
    Gui_text_area_draw_scrolled(x, y, w, h, text, scroll, bg, border, fg)
}

fn Gui_text_area_draw_scrolled(x, y, w, h, text, scroll, bg, border, fg) {
    Gui_panel(x, y, w, h, bg, border)
    let lines = StrVec_from_lines(text)
    let n = lines.len()
    let start = ScrollState_visible_start(scroll)
    let end = ScrollState_visible_end(scroll, n)
    let mut i = start
    let mut row = 0
    while i < end {
        let ly = y + 8 + row * 18
        DrawText(lines.get(i), x + 8, ly, 16, fg)
        row = row + 1
        i = i + 1
    }
}

fn Gui_syntax_color(kind: i32, plain: Color, keyword: Color, string_c: Color, comment: Color, number_c: Color) -> Color {
    if kind == SYNTAX_KEYWORD {
        return keyword
    }
    if kind == SYNTAX_STRING {
        return string_c
    }
    if kind == SYNTAX_COMMENT {
        return comment
    }
    if kind == SYNTAX_NUMBER {
        return number_c
    }
    return plain
}

fn Gui_text_area_syntax_draw(x: i32, y: i32, w: i32, h: i32, text: string, scroll: ScrollState, bg: Color, border: Color, plain: Color, keyword: Color, string_c: Color, comment: Color, number_c: Color) {
    Gui_panel(x, y, w, h, bg, border)
    if Syntax_line_kind(text) == SYNTAX_COMMENT {
        DrawText(text, x + 8, y + 8, 16, comment)
        return
    }
    let lines = StrVec_from_lines(text)
    let n = lines.len()
    let start = ScrollState_visible_start(scroll)
    let end = ScrollState_visible_end(scroll, n)
    let mut i = start
    let mut row = 0
    while i < end {
        let line = lines.get(i)
        let ly = y + 8 + row * 18
        let kind = Syntax_line_kind(line)
        let color = Gui_syntax_color(kind, plain, keyword, string_c, comment, number_c)
        DrawText(line, x + 8, ly, 16, color)
        row = row + 1
        i = i + 1
    }
}

fn Gui_path_join(base, name) {
    let mut sb = StringBuilder_new()
    sb = StringBuilder_push(sb, base)
    if strcmp(base, "/") != 0 {
        sb = StringBuilder_push(sb, "/")
    }
    sb = StringBuilder_push(sb, name)
    return StringBuilder_build(sb)
}
