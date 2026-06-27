import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

fn SpriteEngine_run() {
    Gfx_window_open(800, 600, "Sprite Engine")
    let img = GenImageColor(32, 32, Gfx_color(0xff, 200, 50, 0xff))
    let tex = LoadTextureFromImage(img)
    let mut x = 100
    let mut y = 200
    let mut vx = 2
    while !WindowShouldClose() {
        x = x + vx
        if x > 700 || x < 0 {
            vx = 0 - vx
        }
        Gfx_frame_begin(Gfx_color(20, 30, 50, 0xff))
        DrawTexture(tex, x, y, Gfx_color(0xff, 0xff, 0xff, 0xff))
        DrawText("sprite bounce", 10, 10, 18, Gfx_color(220, 220, 220, 0xff))
        Gfx_frame_end()
    }
    UnloadTexture(tex)
    Gfx_window_close()
}
