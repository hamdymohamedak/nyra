// Same logic as App/NyraApp (Dungeon Steps) for fair runtime comparison.

const GRID: i32 = 4;
const START_HP: i32 = 100;
const MAX_TURNS: i32 = 24;
const TRAP_DAMAGE: i32 = 25;
const GOLD_VALUE: i32 = 15;
const GOAL_BONUS: i32 = 50;
const APP_TITLE: &str = "Dungeon Steps";
const STATUS_PLAYING: i32 = 0;
const STATUS_WON: i32 = 1;
const STATUS_LOST: i32 = 2;

#[derive(Copy, Clone, PartialEq)]
enum Tile {
    Floor,
    Trap,
    Gold,
    Goal,
}

#[derive(Copy, Clone, PartialEq)]
enum Dir {
    North,
    East,
    South,
    West,
}

#[derive(Copy, Clone)]
struct GameState {
    x: i32,
    y: i32,
    hp: i32,
    score: i32,
    turn: i32,
    status: i32,
}

fn tile_at(x: i32, y: i32) -> Tile {
    if x == 3 && y == 3 {
        return Tile::Goal;
    }
    if x == 1 && y == 1 {
        return Tile::Trap;
    }
    if x == 2 && y == 1 {
        return Tile::Gold;
    }
    if x == 1 && y == 3 {
        return Tile::Gold;
    }
    Tile::Floor
}

fn clamp_axis(v: i32) -> i32 {
    if v < 0 {
        return 0;
    }
    if v >= GRID {
        return GRID - 1;
    }
    v
}

fn turn_phase(turn: i32) -> i32 {
    turn % 4
}

fn dir_for_turn(turn: i32) -> Dir {
    match turn_phase(turn) {
        0 | 1 => Dir::East,
        _ => Dir::South,
    }
}

fn new_game() -> GameState {
    GameState {
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
        1
    } else {
        0
    }
}

fn copy_game(x: i32, y: i32, hp: i32, score: i32, turn: i32, status: i32) -> GameState {
    GameState {
        x,
        y,
        hp,
        score,
        turn,
        status,
    }
}

fn trap_hp(hp: i32) -> i32 {
    let h = hp - TRAP_DAMAGE;
    if h <= 0 {
        0
    } else {
        h
    }
}

fn trap_status(hp: i32, playing: i32) -> i32 {
    let h = hp - TRAP_DAMAGE;
    if h <= 0 {
        STATUS_LOST
    } else {
        playing
    }
}

fn apply_tile_at(sx: i32, sy: i32, shp: i32, sscore: i32, sturn: i32, sstatus: i32, tile: Tile) -> GameState {
    match tile {
        Tile::Floor => copy_game(sx, sy, shp, sscore, sturn, sstatus),
        Tile::Gold => copy_game(sx, sy, shp, sscore + GOLD_VALUE, sturn, sstatus),
        Tile::Goal => copy_game(sx, sy, shp, sscore + GOAL_BONUS, sturn, STATUS_WON),
        Tile::Trap => copy_game(sx, sy, trap_hp(shp), sscore, sturn, trap_status(shp, sstatus)),
    }
}

fn advance_parts(sx: i32, sy: i32, shp: i32, sscore: i32, sturn: i32, sstatus: i32, dx: i32, dy: i32) -> GameState {
    let nx = clamp_axis(sx + dx);
    let ny = clamp_axis(sy + dy);
    apply_tile_at(nx, ny, shp, sscore, sturn + 1, sstatus, tile_at(nx, ny))
}

fn move_player(game: GameState, d: Dir) -> GameState {
    let sx = game.x;
    let sy = game.y;
    let shp = game.hp;
    let sscore = game.score;
    let sturn = game.turn;
    let sstatus = game.status;
    match d {
        Dir::East => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0),
        Dir::West => advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0),
        Dir::North => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1),
        Dir::South => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1),
    }
}

fn step_turn(game: GameState) -> GameState {
    let sx = game.x;
    let sy = game.y;
    let shp = game.hp;
    let sscore = game.score;
    let sturn = game.turn;
    let sstatus = game.status;
    if sstatus == STATUS_PLAYING {
        return match dir_for_turn(sturn) {
            Dir::East => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0),
            Dir::West => advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0),
            Dir::North => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1),
            Dir::South => advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1),
        };
    }
    copy_game(sx, sy, shp, sscore, sturn, sstatus)
}

fn run_dungeon() -> i32 {
    let mut game = new_game();
    while is_playing(game) != 0 && game.turn < MAX_TURNS {
        game = step_turn(game);
    }
    if is_playing(game) == 0 {
        return game.score;
    }
    let lost = copy_game(game.x, game.y, game.hp, game.score, game.turn, STATUS_LOST);
    lost.score
}

fn outcome_code(game: GameState) -> i32 {
    game.status
}

fn main() {
    println!("{}", APP_TITLE);
    println!("{}", run_dungeon());
    let g0 = new_game();
    let g1 = move_player(g0, Dir::East);
    println!("{}", outcome_code(g1));
    let mut banner = 0;
    for i in 0..3 {
        banner += i;
    }
    println!("{}", banner);
}
