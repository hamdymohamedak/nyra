import "@root/vendor/bindings/raylib.ny"
import "../../shared/colors.ny"
import "../../shared/window.ny"

const BOARD = 8
const CELL = 72

fn Chess_piece_color(piece) {
    if piece >= 7 {
        return Gfx_color(30, 30, 30, 0xff)
    }
    return Gfx_color(240, 240, 240, 0xff)
}

fn Chess_piece_label(piece) {
    if piece == 1 {
        return "P"
    }
    if piece == 2 {
        return "N"
    }
    if piece == 3 {
        return "B"
    }
    if piece == 4 {
        return "R"
    }
    if piece == 5 {
        return "Q"
    }
    if piece == 6 {
        return "K"
    }
    if piece == 7 {
        return "p"
    }
    if piece == 8 {
        return "n"
    }
    if piece == 9 {
        return "b"
    }
    if piece == 10 {
        return "r"
    }
    if piece == 11 {
        return "q"
    }
    if piece == 12 {
        return "k"
    }
    return ""
}

fn Chess_run() {
    Gfx_window_open(BOARD * CELL, BOARD * CELL, "Chess")
    let board = [
        4, 2, 3, 5, 6, 3, 2, 4,
        1, 1, 1, 1, 1, 1, 1, 1,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0,
        7, 7, 7, 7, 7, 7, 7, 7,
        10, 8, 9, 11, 12, 9, 8, 10,
    ]
    let mut sel = -1
    while !WindowShouldClose() {
        if IsMouseButtonPressed(0) {
            let mx = GetMouseX() / CELL
            let my = GetMouseY() / CELL
            if mx >= 0 && my >= 0 && mx < BOARD && my < BOARD {
                let idx = my * BOARD + mx
                if sel < 0 {
                    if board[idx] != 0 {
                        sel = idx
                    }
                } else {
                    sel = idx
                }
            }
        }
        Gfx_frame_begin(Gfx_color(40, 40, 50, 0xff))
        let mut row = 0
        while row < BOARD {
            let mut col = 0
            while col < BOARD {
                let light = (row + col) % 2 == 0
                let mut bg = Gfx_color(180, 150, 110, 0xff)
                if !light {
                    bg = Gfx_color(110, 80, 50, 0xff)
                }
                let idx = row * BOARD + col
                if idx == sel {
                    bg = Gfx_color(80, 160, 220, 0xff)
                }
                DrawRectangle(col * CELL, row * CELL, CELL, CELL, bg)
                let p = board[idx]
                if p != 0 {
                    DrawText(Chess_piece_label(p), col * CELL + 24, row * CELL + 20, 32, Chess_piece_color(p))
                }
                col = col + 1
            }
            row = row + 1
        }
        DrawText("click to select square", 8, 8, 14, Gfx_color(220, 220, 220, 0xff))
        Gfx_frame_end()
    }
    Gfx_window_close()
}
