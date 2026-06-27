import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const PADDLE_W = 12
const PADDLE_H = 80
const BALL_R = 8

fn Pong_run() {
    Gfx_window_open(800, 600, "Pong")
    let mut ball_x = 400
    let mut ball_y = 300
    let mut ball_vx = 4
    let mut ball_vy = 3
    let mut left_y = 260
    let mut right_y = 260
    let mut score_l = 0
    let mut score_r = 0
    while !WindowShouldClose() {
        if IsKeyDown(87) && left_y > 0 {
            left_y = left_y - 4
        }
        if IsKeyDown(83) && left_y < 600 - PADDLE_H {
            left_y = left_y + 4
        }
        if IsKeyDown(265) && right_y > 0 {
            right_y = right_y - 4
        }
        if IsKeyDown(264) && right_y < 600 - PADDLE_H {
            right_y = right_y + 4
        }
        ball_x = ball_x + ball_vx
        ball_y = ball_y + ball_vy
        if ball_y <= BALL_R || ball_y >= 600 - BALL_R {
            ball_vy = 0 - ball_vy
        }
        if ball_x <= 40 + PADDLE_W && ball_y >= left_y && ball_y <= left_y + PADDLE_H {
            ball_vx = 4
        }
        if ball_x >= 760 - PADDLE_W && ball_y >= right_y && ball_y <= right_y + PADDLE_H {
            ball_vx = -4
        }
        if ball_x < 0 {
            score_r = score_r + 1
            ball_x = 400
            ball_y = 300
            ball_vx = 4
        }
        if ball_x > 800 {
            score_l = score_l + 1
            ball_x = 400
            ball_y = 300
            ball_vx = -4
        }
        Gfx_frame_begin(Gfx_color(20, 20, 30, 0xff))
        DrawRectangle(30, left_y, PADDLE_W, PADDLE_H, Gfx_color(220, 220, 220, 0xff))
        DrawRectangle(760 - PADDLE_W, right_y, PADDLE_W, PADDLE_H, Gfx_color(220, 220, 220, 0xff))
        DrawCircle(ball_x, ball_y, 8.0, Gfx_color(0xff, 200, 60, 0xff))
        DrawLine(400, 0, 400, 600, Gfx_color(80, 80, 100, 0xff))
        let score = strcat(i32_to_string(score_l), strcat(" : ", i32_to_string(score_r)))
        DrawText(score, 380, 20, 24, Gfx_color(200, 200, 200, 0xff))
        DrawText("W/S  arrows", 10, 10, 16, Gfx_color(140, 140, 160, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
