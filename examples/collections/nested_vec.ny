// 2D dynamic grid with Vec<Vec<i32>> — nyra run examples/collections/nested_vec.ny
import "stdlib/vec.ny"
import "stdlib/collections/nested_vec.ny"

fn main() {
    let mut grid: Vec<Vec<i32>> = Vec_Vec_i32_new()

    let row0 = Vec_i32_new()
    Vec_i32_push(row0, 1)
    Vec_i32_push(row0, 2)
    grid = Vec_Vec_i32_push_handle(grid, row0)

    let row1 = Vec_i32_new()
    Vec_i32_push(row1, 3)
    grid = Vec_Vec_i32_push_handle(grid, row1)

    print(Vec_Vec_i32_len(grid))
    let top = Vec_Vec_i32_get(grid, 0)
    print(Vec_i32_get(top, 1))
    Vec_Vec_i32_free(grid)
}
