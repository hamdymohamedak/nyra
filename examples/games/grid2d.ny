import "stdlib/games/grid2d.ny"

fn main() {
    let mut board = Grid2D_i32_new(10, 20, 0)
    board = board.set(3, 4, 1)
    print(board.get(3, 4), board.width, board.height)
}
