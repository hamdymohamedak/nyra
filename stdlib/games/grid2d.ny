import "../vec.ny"

struct Grid2D_i32 {
    width: i32
    height: i32
    cells: ptr
}

fn Grid2D_i32_index(width, row, col) {
    return row * width + col
}

fn Grid2D_i32_new(width, height, fill) {
    let n = width * height
    let cells = Vec_i32_new()
    let mut i = 0
    while i < n {
        Vec_i32_push(cells, fill)
        i = i + 1
    }
    return Grid2D_i32 { width: width, height: height, cells: cells }
}

fn Grid2D_i32_in_bounds(width, height, row, col) {
    if row < 0 || col < 0 {
        return 0
    }
    if row >= height || col >= width {
        return 0
    }
    return 1
}

fn Grid2D_i32_put(cells, width, row, col, value) {
    Vec_i32_set(cells, Grid2D_i32_index(width, row, col), value)
}

impl Grid2D_i32 {
    fn get(self, row, col) {
        if Grid2D_i32_in_bounds(self.width, self.height, row, col) == 0 {
            return 0
        }
        return Vec_i32_get(self.cells, Grid2D_i32_index(self.width, row, col))
    }

    fn set(self, row, col, value) {
        if Grid2D_i32_in_bounds(self.width, self.height, row, col) == 0 {
            return self
        }
        Grid2D_i32_put(self.cells, self.width, row, col, value)
        return self
    }

    fn fill(self, value) {
        let n = self.width * self.height
        let mut i = 0
        while i < n {
            Vec_i32_set(self.cells, i, value)
            i = i + 1
        }
        return self
    }

    fn resize(self, new_width, new_height, fill) {
        let mut out: Grid2D_i32 = Grid2D_i32_new(new_width, new_height, fill)
        let mut copy_h = self.height
        if new_height < copy_h {
            copy_h = new_height
        }
        let mut copy_w = self.width
        if new_width < copy_w {
            copy_w = new_width
        }
        let mut row = 0
        while row < copy_h {
            let mut col = 0
            while col < copy_w {
                let v = self.get(row, col)
                Grid2D_i32_put(out.cells, out.width, row, col, v)
                col = col + 1
            }
            row = row + 1
        }
        return out
    }
}

impl Drop for Grid2D_i32 {
    fn drop(self) -> void {
        Vec_i32_free(self.cells)
    }
}
