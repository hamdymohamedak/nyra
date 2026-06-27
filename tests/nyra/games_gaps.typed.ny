const COLS: i32 = 10
const ROWS: i32 = 5

fn test_array_repeat_mul() -> void {
    let grid: [i32; 50] = [0; COLS * ROWS]
    if grid[0] != 0 {
        print("fail repeat mul")
    }
}

fn test_continue_stmt() -> void {
    let mut i: i32 = 0
    let mut sum: i32 = 0
    while i < 5 {
        i = i + 1
        if i == 3 {
            continue
        }
        sum = sum + i
    }
    if sum != 12 {
        print("fail continue", sum)
    }
}

fn main() -> void {
    test_array_repeat_mul()
    test_continue_stmt()
    print("games_gaps typed ok")
}
