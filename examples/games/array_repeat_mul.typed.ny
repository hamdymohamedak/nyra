const COLS = 4
const ROWS = 5

fn main() -> void {
    let grid: [i32; 20] = [0; COLS * ROWS]
    print(grid[0], grid[COLS * ROWS - 1])
}
