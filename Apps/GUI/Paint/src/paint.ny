import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"
import "../../shared/widgets.ny"

const PAINT_MAX = 512

fn PaintGui_run() {
    Gfx_window_open(900, 640, "Paint")
    let mut x1 = [0; PAINT_MAX]
    let mut y1 = [0; PAINT_MAX]
    let mut x2 = [0; PAINT_MAX]
    let mut y2 = [0; PAINT_MAX]
    let mut stroke_count = 0
    let mut last_x = -1
    let mut last_y = -1
    let ink = Gfx_color(30, 30, 30, 0xff)
    let bg = Gfx_color(250, 250, 248, 0xff)
    let hint = Gfx_color(90, 90, 90, 0xff)
    while !WindowShouldClose() {
        let mx = GetMouseX()
        let my = GetMouseY()
        if IsMouseButtonDown(0) && my > 48 {
            if last_x >= 0 && stroke_count < PAINT_MAX {
                let i = stroke_count
                x1[i] = last_x
                y1[i] = last_y
                x2[i] = mx
                y2[i] = my
                stroke_count = stroke_count + 1
            }
            last_x = mx
            last_y = my
        } else {
            last_x = -1
            last_y = -1
        }
        if IsKeyPressed(67) {
            stroke_count = 0
        }
        Gfx_frame_begin(bg)
        Gui_label(12, 12, "draw with mouse  |  C clear", 16, hint)
        DrawRectangle(0, 44, 900, 2, Gfx_color(200, 200, 200, 0xff))
        let mut di = 0
        while di < stroke_count {
            DrawLine(x1[di], y1[di], x2[di], y2[di], ink)
            di = di + 1
        }
        Gfx_frame_end()
    }
    Gfx_window_close()
}
