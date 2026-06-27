import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const GRID = 20
const CELL = 24
const MAX_LEN = 256

fn Snake_run() {
    Gfx_window_open(GRID * CELL, GRID * CELL, "Snake")
    let mut body_x = [10; MAX_LEN]
    let mut body_y = [10; MAX_LEN]
    let mut len = 3
    let mut dir = 1
    let mut food_x = 15
    let mut food_y = 10
    let mut tick = 0
    while !WindowShouldClose() {
        if IsKeyPressed(262) {
            dir = 1
        }
        if IsKeyPressed(263) {
            dir = 3
        }
        if IsKeyPressed(264) {
            dir = 2
        }
        if IsKeyPressed(265) {
            dir = 0
        }
        tick = tick + 1
        if tick >= 8 {
            tick = 0
            let head_x = body_x[0]
            let head_y = body_y[0]
            let mut nx = head_x
            let mut ny = head_y
            if dir == 0 {
                ny = ny - 1
            }
            if dir == 1 {
                nx = nx + 1
            }
            if dir == 2 {
                ny = ny + 1
            }
            if dir == 3 {
                nx = nx - 1
            }
            if nx < 0 || ny < 0 || nx >= GRID || ny >= GRID {
                len = 3
                body_x[0] = 10
                body_y[0] = 10
                dir = 1
            } else {
                let mut i = len
                while i > 0 {
                    body_x[i] = body_x[i - 1]
                    body_y[i] = body_y[i - 1]
                    i = i - 1
                }
                body_x[0] = nx
                body_y[0] = ny
                if nx == food_x && ny == food_y {
                    if len < MAX_LEN - 1 {
                        len = len + 1
                    }
                    food_x = random_range(1, GRID - 2)
                    food_y = random_range(1, GRID - 2)
                }
            }
        }
        Gfx_frame_begin(Gfx_color(15, 20, 15, 0xff))
        let mut di = 0
        while di < GRID {
            DrawLine(di * CELL, 0, di * CELL, GRID * CELL, Gfx_color(30, 40, 30, 0xff))
            DrawLine(0, di * CELL, GRID * CELL, di * CELL, Gfx_color(30, 40, 30, 0xff))
            di = di + 1
        }
        DrawRectangle(food_x * CELL + 2, food_y * CELL + 2, CELL - 4, CELL - 4, Gfx_color(0xff, 80, 80, 0xff))
        let mut si = 0
        while si < len {
            let mut c = Gfx_color(80, 200, 80, 0xff)
            if si == 0 {
                c = Gfx_color(120, 0xff, 120, 0xff)
            }
            DrawRectangle(body_x[si] * CELL + 1, body_y[si] * CELL + 1, CELL - 2, CELL - 2, c)
            si = si + 1
        }
        DrawText("arrows  eat food", 6, 4, 14, Gfx_color(180, 180, 180, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
