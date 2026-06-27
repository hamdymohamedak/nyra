import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const RAYS = 80

fn Doom_run() {
    Gfx_window_open(640, 480, "Doom Clone (raycast MVP)")
    let mut angle = 0
    while !WindowShouldClose() {
        if IsKeyDown(262) {
            angle = (angle + 1) % 360
        }
        if IsKeyDown(263) {
            angle = (angle + 359) % 360
        }
        Gfx_frame_begin(Gfx_color(20, 20, 30, 0xff))
        let mut ray = 0
        while ray < RAYS {
            let dist = 40 + (ray + angle) % 120
            let mut h = 48000 / (dist + 1)
            if h > 480 {
                h = 480
            }
            let mut shade = 220 - dist
            if shade < 50 {
                shade = 50
            }
            DrawRectangle(ray * 8, (480 - h) / 2, 8, h, Gfx_color(shade, shade / 2, shade / 3, 0xff))
            ray = ray + 1
        }
        DrawText("L/R turn — full raycast needs stdlib sin/cos", 10, 10, 16, Gfx_color(200, 200, 200, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
