import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

fn Renderer2D_run() {
    Gfx_window_open(800, 600, "2D Renderer")
    while !WindowShouldClose() {
        Gfx_frame_begin(Gfx_color(30, 30, 40, 0xff))
        DrawRectangle(100, 100, 200, 120, Gfx_color(80, 160, 220, 0xff))
        DrawCircle(500, 300, 80.0, Gfx_color(220, 120, 80, 0xff))
        DrawLine(50, 500, 750, 550, Gfx_color(200, 200, 100, 0xff))
        DrawLine(400, 300, 520, 300, Gfx_color(0xff, 0xff, 0xff, 0xff))
        DrawText("2D primitives demo", 10, 10, 20, Gfx_color(230, 230, 230, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
