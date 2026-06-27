extern fn strlen(s: string) -> i32
extern fn strcat(a: string, b: string) -> string
extern fn i32_to_string(n: i32) -> string

struct Color {
    r: u8
    g: u8
    b: u8
    a: u8
}

fn Highlight_color_for_line(line){
    if line.contains("error") == 1 || line.contains("Error") == 1 || line.contains("command not found") == 1 {
        return Color { r: 255, g: 95, b: 86, a: 255 }
    }
    return Color { r: 220, g: 220, b: 220, a: 255 }
}

fn Highlight_color_for_command(_cmd){
    return Color { r: 220, g: 220, b: 220, a: 255 }
}

fn Highlight_first_token(line){
    let parts = line.split(" ")
    for p in parts {
        return p
    }
    return line
}

fn Highlight_demo(){
    print("syntax highlight rules:", color: bold)
    print("  git   → green", color: green)
    print("  cd    → cyan", color: cyan)
    print("  rm    → red", color: red)
    print("  ssh   → purple", color: magenta)
    print("  cargo/npm → yellow", color: yellow)
}

struct TermGrid {
    cols: i32
    rows: i32
    cursor_row: i32
    cursor_col: i32
}

fn TermGrid_new(cols, rows){
    return TermGrid {
        cols: cols
        rows: rows
        cursor_row: 0
        cursor_col: 0
    }
}

fn TermGrid_advance(grid, ch_count){
    let mut col = grid.cursor_col + ch_count
    let mut row = grid.cursor_row
    if col >= grid.cols {
        row = row + 1
        col = 0
    }
    return TermGrid {
        cols: grid.cols
        rows: grid.rows
        cursor_row: row
        cursor_col: col
    }
}
