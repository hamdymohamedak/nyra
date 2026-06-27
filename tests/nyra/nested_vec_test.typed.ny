// Nested Vec<Vec<i32>> — v1.22 MVP (typed)
import "stdlib/testing.ny"
import "stdlib/vec.ny"
import "stdlib/collections/nested_vec.ny"

test fn test_nested_vec_i32_push_get() {
    let mut grid = Vec_Vec_i32_new()

    let row0 = Vec_i32_new()
    Vec_i32_push(row0, 1)
    Vec_i32_push(row0, 2)
    grid = Vec_Vec_i32_push_handle(grid, row0)

    let row1 = Vec_i32_new()
    Vec_i32_push(row1, 10)
    Vec_i32_push(row1, 20)
    Vec_i32_push(row1, 30)
    grid = Vec_Vec_i32_push_handle(grid, row1)

    assert_eq(Vec_Vec_i32_len(grid), 2)

    let r0 = Vec_Vec_i32_get(grid, 0)
    assert_eq(Vec_i32_len(r0), 2)
    assert_eq(Vec_i32_get(r0, 0), 1)
    assert_eq(Vec_i32_get(r0, 1), 2)

    let r1 = Vec_Vec_i32_get(grid, 1)
    assert_eq(Vec_i32_get(r1, 2), 30)

    Vec_Vec_i32_free(grid)
}

test fn test_nested_vec_generic_syntax() {
    let mut grid: Vec<Vec<i32>> = Vec_Vec_i32_new()
    let row = Vec_i32_new()
    Vec_i32_push(row, 7)
    grid = Vec_Vec_i32_push_handle(grid, row)
    assert_eq(Vec_Vec_i32_len(grid), 1)
    let got = Vec_Vec_i32_get(grid, 0)
    assert_eq(Vec_i32_get(got, 0), 7)
    Vec_Vec_i32_free(grid)
}
