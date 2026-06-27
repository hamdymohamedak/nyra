import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const PARTICLE_MAX = 64

fn ParticleEngine_run() {
    Gfx_window_open(800, 600, "Particle Engine")
    let mut px = [0; PARTICLE_MAX]
    let mut py = [0; PARTICLE_MAX]
    let mut pvx = [0; PARTICLE_MAX]
    let mut pvy = [0; PARTICLE_MAX]
    let mut i = 0
    while i < PARTICLE_MAX {
        px[i] = 400
        py[i] = 300
        pvx[i] = (i % 5) - 2
        pvy[i] = (i % 7) - 3
        i = i + 1
    }
    while !WindowShouldClose() {
        let mut j = 0
        while j < PARTICLE_MAX {
            px[j] = px[j] + pvx[j]
            py[j] = py[j] + pvy[j]
            if px[j] < 0 || px[j] > 800 {
                pvx[j] = 0 - pvx[j]
            }
            if py[j] < 0 || py[j] > 600 {
                pvy[j] = 0 - pvy[j]
            }
            j = j + 1
        }
        Gfx_frame_begin(Gfx_color(10, 15, 25, 0xff))
        let mut k = 0
        while k < PARTICLE_MAX {
            DrawCircle(px[k], py[k], 4.0, Gfx_color(0xff, 180, 60, 0xff))
            k = k + 1
        }
        DrawText("particle pool (memory)", 10, 10, 18, Gfx_color(200, 200, 200, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
