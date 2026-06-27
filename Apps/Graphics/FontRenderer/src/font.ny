import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

fn FontRenderer_run() {
    Gfx_window_open(800, 600, "Font Renderer")
    while !WindowShouldClose() {
        Gfx_frame_begin(Gfx_color(18, 18, 28, 0xff))
        DrawText("Nyra Font Renderer", 40, 60, 32, Gfx_color(0xff, 0xff, 0xff, 0xff))
        DrawText("size 20 — ASCII readable", 40, 120, 20, Gfx_color(180, 220, 0xff, 0xff))
        DrawText("size 16 — performance test", 40, 160, 16, Gfx_color(200, 0xff, 180, 0xff))
        DrawText("size 12 — memory + windowing", 40, 190, 12, Gfx_color(0xff, 200, 180, 0xff))
        DrawText("!@#$%^&*()_+-=[]{}|;':\",./<>?", 40, 240, 18, Gfx_color(220, 220, 220, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
