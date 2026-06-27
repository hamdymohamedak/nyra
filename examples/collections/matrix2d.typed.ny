// Example: growable 2D matrix (explicit types).
import "stdlib/collections/matrix2d.ny"

fn main() {
    let mut grid: Matrix2D = Matrix2D_new(3, 3)
    grid = grid.put(1, 1, 42)
    print(grid.get(1, 1))
    Matrix2D_free(grid)
}
