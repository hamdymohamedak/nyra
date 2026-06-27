import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

fn PhotoEditor_run(_args) {
    Gfx_window_open(800, 600, "Photo Editor")
    let img = GenImageColor(400, 300, Gfx_color(120, 160, 200, 0xff))
    let mut tex = LoadTextureFromImage(img)
    let mut bright = 0
    while !WindowShouldClose() {
        if IsKeyPressed(66) {
            bright = if bright == 0 { 1 } else { 0 }
        }
        let tint = if bright == 1 {
            Gfx_color(0xff, 0xff, 0xff, 0xff)
        } else {
            Gfx_color(180, 180, 180, 0xff)
        }
        Gfx_frame_begin(Gfx_color(25, 25, 35, 0xff))
        DrawTexture(tex, 200, 150, tint)
        DrawText("B toggle brightness", 10, 10, 18, Gfx_color(220, 220, 220, 0xff))
        Gfx_frame_end()
    }
    UnloadTexture(tex)
    Gfx_window_close()
    return 0
}
