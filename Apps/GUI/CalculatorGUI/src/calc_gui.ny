import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"
import "../../shared/widgets.ny"

const CALC_BTN_W = 72
const CALC_BTN_H = 56
const CALC_GAP = 8
const CALC_COLS = 4

fn CalcGui_apply(a: f64, op: string, b: f64) -> f64 {
    if strcmp(op, "+") == 0 {
        return a + b
    }
    if strcmp(op, "-") == 0 {
        return a - b
    }
    if strcmp(op, "*") == 0 {
        return a * b
    }
    if strcmp(op, "/") == 0 {
        if b == 0.0 {
            return 0.0
        }
        return a / b
    }
    return b
}

fn CalcGui_handle_digit(display, digit, fresh) {
    if fresh == 1 {
        return digit
    }
    if strcmp(display, "0") == 0 {
        return digit
    }
    return strcat(display, digit)
}

fn CalcGui_draw_grid(start_x: i32, start_y: i32, labels: StrVec, count: i32, normal: Color, accent: Color, text: Color) {
    let mut i = 0
    while i < count {
        let col = i % CALC_COLS
        let row = i / CALC_COLS
        let x = start_x + col * (CALC_BTN_W + CALC_GAP)
        let y = start_y + row * (CALC_BTN_H + CALC_GAP)
        let label = labels.get(i)
        let mut bg = normal
        if strcmp(label, "=") == 0 || strcmp(label, "/") == 0 || strcmp(label, "*") == 0 || strcmp(label, "-") == 0 || strcmp(label, "+") == 0 {
            bg = accent
        }
        if strcmp(label, "C") == 0 {
            bg = Gfx_color(220, 120, 90, 0xff)
        }
        Gui_button_draw(x, y, CALC_BTN_W, CALC_BTN_H, label, bg, Gfx_color(40, 40, 40, 0xff), text)
        i = i + 1
    }
}

fn CalcGui_hit_label(start_x, start_y, labels, count) {
    let mut i = 0
    while i < count {
        let col = i % CALC_COLS
        let row = i / CALC_COLS
        let x = start_x + col * (CALC_BTN_W + CALC_GAP)
        let y = start_y + row * (CALC_BTN_H + CALC_GAP)
        if Gui_button_clicked(x, y, CALC_BTN_W, CALC_BTN_H) == 1 {
            return labels.get(i)
        }
        i = i + 1
    }
    return ""
}

fn CalcGui_run() {
    let labels = StrVec_from_lines("7\n8\n9\n/\n4\n5\n6\n*\n1\n2\n3\n-\nC\n0\n=\n+")
    let panel = Gfx_color(28, 28, 32, 0xff)
    let display_bg = Gfx_color(18, 18, 22, 0xff)
    let btn = Gfx_color(58, 58, 66, 0xff)
    let accent = Gfx_color(70, 130, 220, 0xff)
    let ink = Gfx_color(240, 240, 245, 0xff)
    Gfx_window_open(360, 520, "Calculator")
    let mut display = "0"
    let mut stored = 0.0
    let mut pending = ""
    let mut fresh = 1
    let start_x = 24
    let start_y = 120
    while !WindowShouldClose() {
        let hit = CalcGui_hit_label(start_x, start_y, labels, 16)
        if strlen(hit) > 0 {
            if strcmp(hit, "C") == 0 {
                display = "0"
                stored = 0.0
                pending = ""
                fresh = 1
            } else if strcmp(hit, "=") == 0 {
                if strlen(pending) > 0 {
                    let cur = str_to_f64(display)
                    let result = CalcGui_apply(stored, pending, cur)
                    display = f64_to_string(result)
                    stored = result
                    pending = ""
                    fresh = 1
                }
            } else if strcmp(hit, "+") == 0 || strcmp(hit, "-") == 0 || strcmp(hit, "*") == 0 || strcmp(hit, "/") == 0 {
                if strlen(pending) > 0 && fresh == 0 {
                    let cur = str_to_f64(display)
                    stored = CalcGui_apply(stored, pending, cur)
                    display = f64_to_string(stored)
                } else {
                    stored = str_to_f64(display)
                }
                pending = hit
                fresh = 1
            } else {
                display = CalcGui_handle_digit(display, hit, fresh)
                fresh = 0
            }
        }
        Gfx_frame_begin(panel)
        Gui_panel(24, 24, 312, 72, display_bg, Gfx_color(90, 90, 100, 0xff))
        let tw = MeasureText(display, 28)
        DrawText(display, 312 - tw, 48, 28, ink)
        CalcGui_draw_grid(start_x, start_y, labels, 16, btn, accent, ink)
        Gfx_frame_end()
    }
    Gfx_window_close()
}
