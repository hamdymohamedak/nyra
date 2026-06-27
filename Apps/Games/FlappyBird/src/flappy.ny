import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const PIPE_COUNT = 4
const GAP = 140

fn Flappy_run() {
    Gfx_window_open(480, 640, "Flappy Bird")
    let mut bird_y = 320
    let mut bird_vy = 0
    let mut pipe_x = [400; PIPE_COUNT]
    let mut pipe_gap_y = [200; PIPE_COUNT]
    let mut score = 0
    let mut i = 0
    while i < PIPE_COUNT {
        pipe_x[i] = 400 + i * 180
        pipe_gap_y[i] = random_range(120, 420)
        i = i + 1
    }
    while !WindowShouldClose() {
        if IsKeyPressed(32) || IsMouseButtonPressed(0) {
            bird_vy = -8
        }
        bird_vy = bird_vy + 1
        bird_y = bird_y + bird_vy
        if bird_y < 0 {
            bird_y = 0
        }
        if bird_y > 620 {
            bird_y = 320
            bird_vy = 0
            score = 0
        }
        let mut pi = 0
        while pi < PIPE_COUNT {
            pipe_x[pi] = pipe_x[pi] - 3
            if pipe_x[pi] < -60 {
                pipe_x[pi] = 480 + random_range(0, 80)
                pipe_gap_y[pi] = random_range(120, 420)
                score = score + 1
            }
            let px = pipe_x[pi]
            if bird_y > pipe_gap_y[pi] - GAP / 2 && bird_y < pipe_gap_y[pi] + GAP / 2 {
            } else {
                if px < 90 && px > 30 {
                    bird_y = 320
                    bird_vy = 0
                    score = 0
                }
            }
            pi = pi + 1
        }
        Gfx_frame_begin(Gfx_color(80, 180, 0xff, 0xff))
        let mut draw_p = 0
        while draw_p < PIPE_COUNT {
            let gx = pipe_x[draw_p]
            let gy = pipe_gap_y[draw_p]
            DrawRectangle(gx, 0, 52, gy - GAP / 2, Gfx_color(40, 160, 40, 0xff))
            DrawRectangle(gx, gy + GAP / 2, 52, 640 - (gy + GAP / 2), Gfx_color(40, 160, 40, 0xff))
            draw_p = draw_p + 1
        }
        DrawCircle(60, bird_y, 16.0, Gfx_color(0xff, 220, 40, 0xff))
        DrawText(i32_to_string(score), 220, 40, 40, Gfx_color(0xff, 0xff, 0xff, 0xff))
        DrawText("space / click flap", 10, 10, 16, Gfx_color(0xff, 0xff, 0xff, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
