const SIZE = 9
const BOARD_CELLS = 81

fn Sudoku_run() {
    let mut board = [
        5, 3, 0, 0, 7, 0, 0, 0, 0,
        6, 0, 0, 1, 9, 5, 0, 0, 0,
        0, 9, 8, 0, 0, 0, 0, 6, 0,
        8, 0, 0, 0, 6, 0, 0, 0, 3,
        4, 0, 0, 8, 0, 3, 0, 0, 1,
        7, 0, 0, 0, 2, 0, 0, 0, 6,
        0, 6, 0, 0, 0, 0, 2, 8, 0,
        0, 0, 0, 4, 1, 9, 0, 0, 5,
        0, 0, 0, 0, 8, 0, 0, 7, 9,
    ]
    print("Puzzle (classic easy):")
    print("--- Sudoku 9x9 ---", color: bold)
    let mut prow = 0
    while prow < SIZE {
        let mut pcol = 0
        let mut pline = ""
        while pcol < SIZE {
            let pv = board[prow * SIZE + pcol]
            if pv == 0 {
                pline = strcat(pline, ". ")
            } else {
                pline = strcat(pline, strcat(i32_to_string(pv), " "))
            }
            if pcol == 2 || pcol == 5 {
                pline = strcat(pline, "| ")
            }
            pcol = pcol + 1
        }
        print(pline)
        if prow == 2 || prow == 5 {
            print("------+-------+------")
        }
        prow = prow + 1
    }
    let mut solved = 0
    let mut guard = 0
    while solved == 0 && guard < 500 {
        guard = guard + 1
        let mut row = 0
        let mut stuck = 1
        while row < SIZE {
            let mut col = 0
            while col < SIZE {
                let i = row * SIZE + col
                if board[i] == 0 {
                    stuck = 0
                    let mut n = 1
                    while n <= 9 {
                        let mut ok = 1
                        let mut c = 0
                        while c < SIZE {
                            if board[row * SIZE + c] == n {
                                ok = 0
                            }
                            c = c + 1
                        }
                        let mut r = 0
                        while r < SIZE {
                            if board[r * SIZE + col] == n {
                                ok = 0
                            }
                            r = r + 1
                        }
                        let br = (row / 3) * 3
                        let bc = (col / 3) * 3
                        let mut dr = 0
                        while dr < 3 {
                            let mut dc = 0
                            while dc < 3 {
                                if board[(br + dr) * SIZE + bc + dc] == n {
                                    ok = 0
                                }
                                dc = dc + 1
                            }
                            dr = dr + 1
                        }
                        if ok != 0 {
                            board[i] = n
                            n = 10
                        }
                        n = n + 1
                    }
                }
                col = col + 1
            }
            row = row + 1
        }
        if stuck != 0 {
            solved = 1
        }
    }
    if solved != 0 {
        print("Solved (MVP greedy fill):", color: green)
        let mut srow = 0
        while srow < SIZE {
            let mut scol = 0
            let mut sline = ""
            while scol < SIZE {
                let sv = board[srow * SIZE + scol]
                sline = strcat(sline, strcat(i32_to_string(sv), " "))
                if scol == 2 || scol == 5 {
                    sline = strcat(sline, "| ")
                }
                scol = scol + 1
            }
            print(sline)
            srow = srow + 1
        }
    } else {
        print("Could not solve with MVP filler.", color: red)
    }
}
