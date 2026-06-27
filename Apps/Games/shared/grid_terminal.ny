// Terminal grid helpers for text-based games (Minesweeper, Sudoku).

fn Grid_cell_label(hidden, mine, adjacent, revealed) {
    if revealed == 0 {
        return "?"
    }
    if mine != 0 {
        return "*"
    }
    if adjacent == 0 {
        return "."
    }
    return i32_to_string(adjacent)
}

fn Grid_row_line(cells, width, row) {
    let mut out = ""
    let mut col = 0
    while col < width {
        let i = row * width + col
        out = strcat(out, cells.get(i))
        out = strcat(out, " ")
        col = col + 1
    }
    return out
}
