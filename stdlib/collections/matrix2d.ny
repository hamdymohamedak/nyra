// Growable 2D matrix (row-major flat storage). Dynamic rows/cols resize.
import "../vec.ny"

struct Matrix2D {
    data: ptr
    rows: i32
    cols: i32
}

fn Matrix2D_new(rows: i32, cols: i32) -> Matrix2D {
    let m = Matrix2D { data: Vec_i32_new(), rows: 0, cols: cols }
    return Matrix2D_resize_rows(m, rows)
}

fn Matrix2D_resize_rows(m: Matrix2D, new_rows: i32) -> Matrix2D {
    while m.rows < new_rows {
        let mut c = 0
        while c < m.cols {
            Vec_i32_push(m.data, 0)
            c = c + 1
        }
        m.rows = m.rows + 1
    }
    return m
}

fn Matrix2D_resize_cols(m: Matrix2D, new_cols: i32) -> Matrix2D {
    if new_cols == m.cols {
        return m
    }
    let old_cols = m.cols
    let new_data = Vec_i32_new()
    let mut r = 0
    while r < m.rows {
        let mut c = 0
        while c < new_cols {
            if c < old_cols {
                Vec_i32_push(new_data, Vec_i32_get(m.data, r * old_cols + c))
            } else {
                Vec_i32_push(new_data, 0)
            }
            c = c + 1
        }
        r = r + 1
    }
    Vec_i32_free(m.data)
    return Matrix2D { data: new_data, rows: m.rows, cols: new_cols }
}

fn Matrix2D_rows(m: Matrix2D) -> i32 {
    return m.rows
}

fn Matrix2D_cols(m: Matrix2D) -> i32 {
    return m.cols
}

fn Matrix2D_index(m: Matrix2D, row: i32, col: i32) -> i32 {
    return row * m.cols + col
}

fn Matrix2D_get(m: Matrix2D, row: i32, col: i32) -> i32 {
    return Vec_i32_get(m.data, Matrix2D_index(m, row, col))
}

fn Matrix2D_put(m: Matrix2D, row: i32, col: i32, value: i32) -> Matrix2D {
    let idx = Matrix2D_index(m, row, col)
    let len = Vec_i32_len(m.data)
    if idx < len {
        let mut i = 0
        let tmp = Vec_i32_new()
        while i < len {
            if i == idx {
                Vec_i32_push(tmp, value)
            } else {
                Vec_i32_push(tmp, Vec_i32_get(m.data, i))
            }
            i = i + 1
        }
        Vec_i32_free(m.data)
        m.data = tmp
    }
    return m
}

fn Matrix2D_free(m: Matrix2D) -> void {
    Vec_i32_free(m.data)
}

impl Matrix2D {
    fn get(self, row: i32, col: i32) -> i32 {
        return Matrix2D_get(self, row, col)
    }

    fn put(self, row: i32, col: i32, value: i32) -> Matrix2D {
        return Matrix2D_put(self, row, col, value)
    }

    fn rows(self) -> i32 {
        return Matrix2D_rows(self)
    }

    fn cols(self) -> i32 {
        return Matrix2D_cols(self)
    }
}
