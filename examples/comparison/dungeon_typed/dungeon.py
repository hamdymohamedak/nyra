# Same logic as App/NyraApp (Dungeon Steps) for fair runtime comparison.

GRID = 4
START_HP = 100
MAX_TURNS = 24
TRAP_DAMAGE = 25
GOLD_VALUE = 15
GOAL_BONUS = 50
APP_TITLE = "Dungeon Steps"
STATUS_PLAYING = 0
STATUS_WON = 1
STATUS_LOST = 2


class Tile:
    Floor = 0
    Trap = 1
    Gold = 2
    Goal = 3


class Dir:
    North = 0
    East = 1
    South = 2
    West = 3


def tile_at(x, y):
    if x == 3 and y == 3:
        return Tile.Goal
    if x == 1 and y == 1:
        return Tile.Trap
    if x == 2 and y == 1:
        return Tile.Gold
    if x == 1 and y == 3:
        return Tile.Gold
    return Tile.Floor


def clamp_axis(v):
    if v < 0:
        return 0
    if v >= GRID:
        return GRID - 1
    return v


def turn_phase(turn):
    return turn % 4


def dir_for_turn(turn):
    phase = turn_phase(turn)
    if phase in (0, 1):
        return Dir.East
    return Dir.South


def new_game():
    return {"x": 0, "y": 0, "hp": START_HP, "score": 0, "turn": 0, "status": STATUS_PLAYING}


def is_playing(game):
    return 1 if game["status"] == STATUS_PLAYING else 0


def copy_game(x, y, hp, score, turn, status):
    return {"x": x, "y": y, "hp": hp, "score": score, "turn": turn, "status": status}


def trap_hp(hp):
    h = hp - TRAP_DAMAGE
    return 0 if h <= 0 else h


def trap_status(hp, playing):
    h = hp - TRAP_DAMAGE
    return STATUS_LOST if h <= 0 else playing


def apply_tile_at(sx, sy, shp, sscore, sturn, sstatus, tile):
    if tile == Tile.Floor:
        return copy_game(sx, sy, shp, sscore, sturn, sstatus)
    if tile == Tile.Gold:
        return copy_game(sx, sy, shp, sscore + GOLD_VALUE, sturn, sstatus)
    if tile == Tile.Goal:
        return copy_game(sx, sy, shp, sscore + GOAL_BONUS, sturn, STATUS_WON)
    if tile == Tile.Trap:
        return copy_game(sx, sy, trap_hp(shp), sscore, sturn, trap_status(shp, sstatus))
    return copy_game(sx, sy, shp, sscore, sturn, sstatus)


def advance_parts(sx, sy, shp, sscore, sturn, sstatus, dx, dy):
    nx = clamp_axis(sx + dx)
    ny = clamp_axis(sy + dy)
    return apply_tile_at(nx, ny, shp, sscore, sturn + 1, sstatus, tile_at(nx, ny))


def move_player(game, d):
    sx, sy = game["x"], game["y"]
    shp, sscore = game["hp"], game["score"]
    sturn, sstatus = game["turn"], game["status"]
    if d == Dir.East:
        return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0)
    if d == Dir.West:
        return advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0)
    if d == Dir.North:
        return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1)
    if d == Dir.South:
        return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1)
    return game


def step_turn(game):
    sx, sy = game["x"], game["y"]
    shp, sscore = game["hp"], game["score"]
    sturn, sstatus = game["turn"], game["status"]
    if sstatus == STATUS_PLAYING:
        d = dir_for_turn(sturn)
        if d == Dir.East:
            return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0)
        if d == Dir.West:
            return advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0)
        if d == Dir.North:
            return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1)
        if d == Dir.South:
            return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1)
    return copy_game(sx, sy, shp, sscore, sturn, sstatus)


def run_dungeon():
    game = new_game()
    while is_playing(game) != 0 and game["turn"] < MAX_TURNS:
        game = step_turn(game)
    if is_playing(game) == 0:
        return game["score"]
    lost = copy_game(game["x"], game["y"], game["hp"], game["score"], game["turn"], STATUS_LOST)
    return lost["score"]


def outcome_code(game):
    return game["status"]


def main():
    print(APP_TITLE)
    print(run_dungeon())
    g0 = new_game()
    g1 = move_player(g0, Dir.East)
    print(outcome_code(g1))
    banner = 0
    for i in range(3):
        banner = banner + i
    print(banner)


if __name__ == "__main__":
    main()
