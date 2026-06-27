const WIDTH = 8
const HEIGHT = 8
const CELLS = 64

fn Minesweeper_run() {
    let mut mines = [0; CELLS]
    let mut adjacent = [0; CELLS]
    let mut revealed = [0; CELLS]
    let mut placed = 0
    while placed < 10 {
        let idx = random_range(0, CELLS - 1)
        if mines[idx] == 0 {
            mines[idx] = 1
            placed = placed + 1
        }
    }
    let mut i = 0
    while i < CELLS {
        let row = i / WIDTH
        let col = i % WIDTH
        let mut count = 0
        let mut dr = -1
        while dr <= 1 {
            let mut dc = -1
            while dc <= 1 {
                if dr != 0 || dc != 0 {
                    let nr = row + dr
                    let nc = col + dc
                    if nr >= 0 && nc >= 0 && nr < HEIGHT && nc < WIDTH {
                        if mines[nr * WIDTH + nc] != 0 {
                            count = count + 1
                        }
                    }
                }
                dc = dc + 1
            }
            dr = dr + 1
        }
        adjacent[i] = count
        i = i + 1
    }
    print("Minesweeper — reveal cells by index (0-63). Type 'q' to quit.")
    let mut playing = 1
    while playing != 0 {
        print("--- Minesweeper (8x8) ---", color: bold)
        let mut pr = 0
        while pr < HEIGHT {
            let mut pc = 0
            let mut line = ""
            while pc < WIDTH {
                let pi = pr * WIDTH + pc
                if revealed[pi] == 0 {
                    line = strcat(line, "? ")
                } else {
                    if mines[pi] != 0 {
                        line = strcat(line, "* ")
                    } else {
                        if adjacent[pi] == 0 {
                            line = strcat(line, ". ")
                        } else {
                            line = strcat(line, strcat(i32_to_string(adjacent[pi]), " "))
                        }
                    }
                }
                pc = pc + 1
            }
            print(line)
            pr = pr + 1
        }
        let raw = stdin_read_line("reveal index> ")
        if raw == "q" {
            playing = 0
        } else {
            let idx = str_to_i32(raw)
            if idx >= 0 && idx < CELLS {
                revealed[idx] = 1
                if mines[idx] != 0 {
                    print("BOOM! Game over.", color: red)
                    playing = 0
                }
            } else {
                print("invalid index")
            }
        }
    }
}
