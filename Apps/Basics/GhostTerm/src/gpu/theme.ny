import "@root/vendor/bindings/raylib.ny"

fn GpuTheme_bg_dark(){
    let r= 20
    let g= 20
    let b= 22
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_bg_panel(){
    let r= 32
    let g= 32
    let b= 36
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_bg_tab(){
    let r= 42
    let g= 42
    let b= 48
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_bg_tab_active(){
    let r= 52
    let g= 52
    let b= 60
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_accent(){
    let r= 34
    let g= 211
    let b= 238
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_accent_private(){
    let r= 167
    let g= 139
    let b= 250
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_default(){
    let r= 235
    let g= 235
    let b= 240
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_dim(){
    let r= 120
    let g= 120
    let b= 128
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_prompt(){
    let r= 74
    let g= 222
    let b= 128
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_dir(){
    let r= 96
    let g= 165
    let b= 250
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_exec(){
    let r= 74
    let g= 222
    let b= 128
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_link(){
    let r= 56
    let g= 189
    let b= 248
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_warn(){
    let r= 250
    let g= 204
    let b= 21
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_private(){
    let r= 196
    let g= 181
    let b= 253
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_fg_error(){
    let r= 248
    let g= 113
    let b= 113
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

fn GpuTheme_cursor(){
    let r= 235
    let g= 235
    let b= 240
    let a= 255
    return Color { r: r, g: g, b: b, a: a }
}

const CELL_W = 10
const CELL_H = 20
const FONT_SIZE = 18
const PROMPT_W = 22
const TAB_BAR_H = 34
const STATUS_BAR_H = 24
const PAD_X = 14
const PAD_Y = 8

const WIN_W = 1024
const WIN_H = 640

const TAB_KIND_SHELL = 0
const TAB_KIND_PRIVATE = 1
const TAB_KIND_SANDBOX = 2

fn GpuTerm_body_h(){
    return WIN_H - TAB_BAR_H - STATUS_BAR_H
}

fn GpuTerm_visible_rows(){
    let h = GpuTerm_body_h() - PAD_Y * 2
    let rows = h / CELL_H
    if rows < 3 {
        return 3
    }
    return rows
}

fn GpuTerm_scroll_rows(){
    return GpuTerm_visible_rows() - 1
}

fn GpuTerm_input_row(){
    return GpuTerm_scroll_rows()
}

fn GpuTerm_cols(){
    let w = WIN_W - PAD_X * 2
    return w / CELL_W
}

fn GpuTerm_row_y(row){
    return TAB_BAR_H + PAD_Y + row * CELL_H
}
