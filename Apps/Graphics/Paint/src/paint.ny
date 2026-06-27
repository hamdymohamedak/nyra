import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const STROKE_MAX = 256

fn Paint_run() {
    Gfx_window_open(800, 600, "Paint")
    let mut x1 = [0; STROKE_MAX]
    let mut y1 = [0; STROKE_MAX]
    let mut x2 = [0; STROKE_MAX]
    let mut y2 = [0; STROKE_MAX]
    let mut stroke_count = 0
    let mut last_x = -1
    let mut last_y = -1
    let ink = Gfx_color(30, 30, 30, 0xff)
    while !WindowShouldClose() {
        let mx = GetMouseX()
        let my = GetMouseY()
        if IsMouseButtonDown(0) {
            if last_x >= 0 && stroke_count < STROKE_MAX {
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
        Gfx_frame_begin(Gfx_color(0xff, 0xff, 0xff, 0xff))
        let mut di = 0
        while di < stroke_count {
            DrawLine(x1[di], y1[di], x2[di], y2[di], ink)
            di = di + 1
        }
        DrawText("draw  C clear", 10, 10, 16, Gfx_color(80, 80, 80, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
