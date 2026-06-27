import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const BRICK_COLS = 10
const BRICK_ROWS = 5
const BRICK_COUNT = 50
const BRICK_W = 72
const BRICK_H = 24

fn Breakout_run() {
    Gfx_window_open(720, 540, "Breakout")
    let mut bricks = [1; BRICK_COUNT]
    let mut ball_x = 360
    let mut ball_y = 400
    let mut ball_vx = 3
    let mut ball_vy = -3
    let mut paddle_x = 300
    while !WindowShouldClose() {
        if IsKeyDown(262) {
            paddle_x = paddle_x + 6
        }
        if IsKeyDown(263) {
            paddle_x = paddle_x - 6
        }
        if paddle_x < 0 {
            paddle_x = 0
        }
        if paddle_x > 720 - 100 {
            paddle_x = 720 - 100
        }
        ball_x = ball_x + ball_vx
        ball_y = ball_y + ball_vy
        if ball_x <= 8 || ball_x >= 712 {
            ball_vx = 0 - ball_vx
        }
        if ball_y <= 8 {
            ball_vy = 3
        }
        if ball_y >= 500 && ball_y <= 520 && ball_x >= paddle_x && ball_x <= paddle_x + 100 {
            ball_vy = -3
        }
        if ball_y > 540 {
            ball_x = 360
            ball_y = 400
            ball_vy = -3
        }
        let mut bi = 0
        while bi < BRICK_COLS * BRICK_ROWS {
            if bricks[bi] != 0 {
                let bx = (bi % BRICK_COLS) * BRICK_W
                let by = (bi / BRICK_COLS) * BRICK_H + 40
                if ball_x >= bx && ball_x <= bx + BRICK_W && ball_y >= by && ball_y <= by + BRICK_H {
                    bricks[bi] = 0
                    ball_vy = 0 - ball_vy
                }
            }
            bi = bi + 1
        }
        Gfx_frame_begin(Gfx_color(15, 15, 25, 0xff))
        let mut draw_i = 0
        while draw_i < BRICK_COLS * BRICK_ROWS {
            if bricks[draw_i] != 0 {
                let bx = (draw_i % BRICK_COLS) * BRICK_W
                let by = (draw_i / BRICK_COLS) * BRICK_H + 40
                DrawRectangle(bx + 2, by + 2, BRICK_W - 4, BRICK_H - 4, Gfx_color(180, 80, 80, 0xff))
            }
            draw_i = draw_i + 1
        }
        DrawRectangle(paddle_x, 500, 100, 16, Gfx_color(200, 200, 220, 0xff))
        DrawCircle(ball_x, ball_y, 8.0, Gfx_color(0xff, 220, 80, 0xff))
        DrawText("L/R paddle", 10, 10, 16, Gfx_color(160, 160, 180, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
