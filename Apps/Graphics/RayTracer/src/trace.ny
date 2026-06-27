import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

fn Trace_hit_sphere(ox, oy, oz, dx, dy, dz) {
    let cx = 0.0
    let cy = 0.0
    let cz = 3.0
    let r = 1.0
    let lx = ox - cx
    let ly = oy - cy
    let lz = oz - cz
    let b = lx * dx + ly * dy + lz * dz
    let c = lx * lx + ly * ly + lz * lz - r * r
    let disc = b * b - c
    if disc < 0.0 {
        return 0
    }
    return 1
}

fn Trace_draw_hit(px, py, c) {
    DrawPixel(px * 2, py * 2, c)
    DrawPixel(px * 2 + 1, py * 2, c)
    DrawPixel(px * 2, py * 2 + 1, c)
    DrawPixel(px * 2 + 1, py * 2 + 1, c)
}

fn RayTracer_run() {
    Gfx_window_open(640, 400, "Ray Tracer")
    SetTargetFPS(30)
    let hit_color = Gfx_color(220, 80, 80, 0xff)
    time_start("frame")
    while !WindowShouldClose() {
        Gfx_frame_begin(Gfx_color(10, 10, 20, 0xff))
        let mut py = 0
        while py < 200 {
            let mut px = 0
            while px < 320 {
                let u = (px - 160) / 160.0
                let v = (py - 100) / 100.0
                if Trace_hit_sphere(0.0, 0.0, 0.0, u, v, 1.0) == 1 {
                    Trace_draw_hit(px, py, hit_color)
                }
                px = px + 1
            }
            py = py + 1
        }
        DrawText("CPU ray trace (sphere)", 10, 10, 16, Gfx_color(200, 200, 200, 0xff))
        Gfx_frame_end()
    }
    time_end("frame")
    Gfx_window_close()
}
