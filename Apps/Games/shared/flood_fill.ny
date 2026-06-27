// Flood-fill reveal for grid games (Minesweeper).

fn Grid_flood_reveal(mut revealed, mines, adjacent, width, height, start) {
    let mut stack = [start; 64]
    let mut top = 1
    while top > 0 {
        top = top - 1
        let idx = stack[top]
        if revealed[idx] != 0 {
            continue
        }
        revealed[idx] = 1
        if mines[idx] != 0 {
            continue
        }
        if adjacent[idx] != 0 {
            continue
        }
        let row = idx / width
        let col = idx % width
        let mut dr = -1
        while dr <= 1 {
            let mut dc = -1
            while dc <= 1 {
                if dr != 0 || dc != 0 {
                    let nr = row + dr
                    let nc = col + dc
                    if nr >= 0 && nc >= 0 && nr < height && nc < width {
                        let ni = nr * width + nc
                        if revealed[ni] == 0 && top < 64 {
                            stack[top] = ni
                            top = top + 1
                        }
                    }
                }
                dc = dc + 1
            }
            dr = dr + 1
        }
    }
}
