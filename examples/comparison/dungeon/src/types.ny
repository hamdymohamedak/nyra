enum Tile {
    Floor
    Trap
    Gold
    Goal
}

enum Dir {
    North
    East
    South
    West
}

struct GameState {
    x: i32
    y: i32
    hp: i32
    score: i32
    turn: i32
    status: i32
}
