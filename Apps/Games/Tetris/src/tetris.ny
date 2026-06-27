import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const COLS = 10
const ROWS = 20
const CELL = 28
const BOARD_CELLS = 200

fn Tetris_run() {
    Gfx_window_open(COLS * CELL + 120, ROWS * CELL, "Tetris")
    let mut board = [0; BOARD_CELLS]
    let mut piece_x = 4
    let mut piece_y = 0
    let mut piece = 1
    let mut tick = 0
    while !WindowShouldClose() {
        if IsKeyPressed(262) {
            piece_x = piece_x + 1
        }
        if IsKeyPressed(263) {
            piece_x = piece_x - 1
        }
        if IsKeyPressed(264) {
            piece_y = piece_y + 1
        }
        tick = tick + 1
        if tick >= 12 {
            tick = 0
            piece_y = piece_y + 1
            if piece_y > ROWS - 2 {
                let idx = piece_y * COLS + piece_x
                if idx >= 0 && idx < COLS * ROWS {
                    board[idx] = piece
                }
                piece_y = 0
                piece_x = 4
                piece = (piece % 4) + 1
            }
        }
        Gfx_frame_begin(Gfx_color(10, 10, 20, 0xff))
        let mut r = 0
        while r < ROWS {
            let mut c = 0
            while c < COLS {
                let v = board[r * COLS + c]
                if v != 0 {
                    DrawRectangle(c * CELL, r * CELL, CELL - 1, CELL - 1, Gfx_color(60, 160, 220, 0xff))
                }
                c = c + 1
            }
            r = r + 1
        }
        let mut pc = Gfx_color(220, 120, 60, 0xff)
        if piece == 2 {
            pc = Gfx_color(120, 220, 80, 0xff)
        }
        if piece == 3 {
            pc = Gfx_color(220, 80, 180, 0xff)
        }
        if piece == 4 {
            pc = Gfx_color(0xff, 0xff, 80, 0xff)
        }
        DrawRectangle(piece_x * CELL, piece_y * CELL, CELL - 1, CELL - 1, pc)
        DrawRectangle(COLS * CELL + 10, 10, 100, 80, Gfx_color(30, 30, 50, 0xff))
        DrawText("Tetris MVP", COLS * CELL + 16, 20, 16, Gfx_color(200, 200, 220, 0xff))
        DrawText("L/R/D move", COLS * CELL + 16, 50, 14, Gfx_color(160, 160, 180, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
