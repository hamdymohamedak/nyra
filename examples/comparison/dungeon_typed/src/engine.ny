import "types.ny"
import "config.ny"
import "world.ny"

fn new_game() -> GameState {
    return GameState {
        x: 0,
        y: 0,
        hp: START_HP,
        score: 0,
        turn: 0,
        status: STATUS_PLAYING,
    }
}

fn is_playing(game: GameState) -> i32 {
    if game.status == STATUS_PLAYING {
        return 1
    }
    return 0
}

fn copy_game(x: i32, y: i32, hp: i32, score: i32, turn: i32, status: i32) -> GameState {
    return GameState {
        x: x,
        y: y,
        hp: hp,
        score: score,
        turn: turn,
        status: status,
    }
}

fn trap_hp(hp: i32) -> i32 {
    let h = hp - TRAP_DAMAGE
    if h <= 0 {
        return 0
    }
    return h
}

fn trap_status(hp: i32, playing: i32) -> i32 {
    let h = hp - TRAP_DAMAGE
    if h <= 0 {
        return STATUS_LOST
    }
    return playing
}

fn apply_tile_at(
    sx: i32,
    sy: i32,
    shp: i32,
    sscore: i32,
    sturn: i32,
    sstatus: i32,
    tile: Tile,
) -> GameState {
    return match tile {
        Tile.Floor => copy_game(sx, sy, shp, sscore, sturn, sstatus)
        Tile.Gold => copy_game(sx, sy, shp, sscore + GOLD_VALUE, sturn, sstatus)
        Tile.Goal => copy_game(sx, sy, shp, sscore + GOAL_BONUS, sturn, STATUS_WON)
        Tile.Trap => copy_game(sx, sy, trap_hp(shp), sscore, sturn, trap_status(shp, sstatus))
    }
}

fn advance_parts(
    sx: i32,
    sy: i32,
    shp: i32,
    sscore: i32,
    sturn: i32,
    sstatus: i32,
    dx: i32,
    dy: i32,
) -> GameState {
    return apply_tile_at(
        clamp_axis(sx + dx),
        clamp_axis(sy + dy),
        shp,
        sscore,
        sturn + 1,
        sstatus,
        tile_at(clamp_axis(sx + dx), clamp_axis(sy + dy))
    )
}

fn move_player(game: GameState, dir: Dir) -> GameState {
    let sx = game.x
    let sy = game.y
    let shp = game.hp
    let sscore = game.score
    let sturn = game.turn
    let sstatus = game.status
    return match dir {
        Dir.East => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0)
        Dir.West => advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0)
        Dir.North => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1)
        Dir.South => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1)
    }
}

fn step_turn(game: GameState) -> GameState {
    let sx = game.x
    let sy = game.y
    let shp = game.hp
    let sscore = game.score
    let sturn = game.turn
    let sstatus = game.status
    if sstatus == STATUS_PLAYING {
        return match dir_for_turn(sturn) {
            Dir.East => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0)
            Dir.West => advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0)
            Dir.North => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1)
            Dir.South => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1)
        }
    }
    return copy_game(sx, sy, shp, sscore, sturn, sstatus)
}

fn run_dungeon() -> i32 {
    let mut game = new_game()
    while is_playing(game) != 0 && game.turn < MAX_TURNS {
        game = step_turn(game)
    }
    if is_playing(game) == 0 {
        return game.score
    }
    let sx = game.x
    let sy = game.y
    let shp = game.hp
    let sscore = game.score
    let sturn = game.turn
    let lost = copy_game(sx, sy, shp, sscore, sturn, STATUS_LOST)
    return lost.score
}

fn outcome_code(game: GameState) -> i32 {
    return game.status
}
