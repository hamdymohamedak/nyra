import "types.ny"
import "config.ny"

fn tile_at(x: i32, y: i32) -> Tile {
    if x == 3 {
        if y == 3 {
            return Tile.Goal
        }
    }
    if x == 1 {
        if y == 1 {
            return Tile.Trap
        }
    }
    if x == 2 {
        if y == 1 {
            return Tile.Gold
        }
    }
    if x == 1 {
        if y == 3 {
            return Tile.Gold
        }
    }
    return Tile.Floor
}

fn clamp_axis(v: i32) -> i32 {
    if v < 0 {
        return 0
    }
    if v >= GRID {
        return GRID - 1
    }
    return v
}

fn turn_phase(turn: i32) -> i32 {
    return turn % 4
}

fn dir_for_turn(turn: i32) -> Dir {
    let phase = turn_phase(turn)
    if phase == 0 {
        return Dir.East
    }
    if phase == 1 {
        return Dir.East
    }
    if phase == 2 {
        return Dir.South
    }
    return Dir.South
}
