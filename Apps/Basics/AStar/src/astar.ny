const GRID_W = 5
const GRID_H = 5

struct Grid {
    width: i32
    height: i32
    blocked: [i32; 25]
}

fn Grid_new(){
    return Grid {
        width: GRID_W,
        height: GRID_H,
        blocked: [0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    }
}

fn Grid_idx(g, x, y){
    return y * g.width + x
}

fn Grid_walkable(g, x, y){
    if x < 0 || y < 0 || x >= g.width || y >= g.height {
        return 0
    }
    return if g.blocked[Grid_idx(g, x, y)] == 0 { 1 } else { 0 }
}

fn AStar_manhattan(x, y, gx, gy){
    let dx = if x > gx { x - gx } else { gx - x }
    let dy = if y > gy { y - gy } else { gy - y }
    return dx + dy
}

fn AStar_run(){
    print("A* pathfinding (grid, Manhattan heuristic):")
    let g = Grid_new()
    let sx = 0
    let sy = 0
    let gx = GRID_W - 1
    let gy = GRID_H - 1
    let mut x = sx
    let mut y = sy
    let mut steps = 0
    while steps < 20 && (x != gx || y != gy) {
        print(`(${x}, ${y})`)
        let mut best_x = x
        let mut best_y = y
        let mut best_f = 999
        let mut dx = -1
        while dx <= 1 {
            let mut dy = -1
            while dy <= 1 {
                if dx != 0 || dy != 0 {
                    let nx = x + dx
                    let ny = y + dy
                    if Grid_walkable(g, nx, ny) == 1 {
                        let h = AStar_manhattan(nx, ny, gx, gy)
                        if h < best_f {
                            best_f = h
                            best_x = nx
                            best_y = ny
                        }
                    }
                }
                dy = dy + 1
            }
            dx = dx + 1
        }
        x = best_x
        y = best_y
        steps = steps + 1
    }
    print(`goal (${gx}, ${gy})`)
}
