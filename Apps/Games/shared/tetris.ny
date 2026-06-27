// Tetris piece rotation helpers (4x4 matrices as flat [16] arrays).

const TETRIS_I = [
    0, 0, 0, 0,
    1, 1, 1, 1,
    0, 0, 0, 0,
    0, 0, 0, 0,
]

fn Tetris_rotate_cw(mut shape) {
    let mut out = [0; 16]
    let mut row = 0
    while row < 4 {
        let mut col = 0
        while col < 4 {
            out[col * 4 + (3 - row)] = shape[row * 4 + col]
            col = col + 1
        }
        row = row + 1
    }
    let mut i = 0
    while i < 16 {
        shape[i] = out[i]
        i = i + 1
    }
}

fn Tetris_shape_get(shape, row, col) {
    return shape[row * 4 + col]
}
