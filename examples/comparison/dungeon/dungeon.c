/* Same logic as App/NyraApp (Dungeon Steps) for fair runtime comparison. */
#include <stdio.h>
#include <stdint.h>

enum {
    GRID = 4,
    START_HP = 100,
    MAX_TURNS = 24,
    TRAP_DAMAGE = 25,
    GOLD_VALUE = 15,
    GOAL_BONUS = 50,
    STATUS_PLAYING = 0,
    STATUS_WON = 1,
    STATUS_LOST = 2,
    TILE_FLOOR = 0,
    TILE_TRAP = 1,
    TILE_GOLD = 2,
    TILE_GOAL = 3,
    DIR_NORTH = 0,
    DIR_EAST = 1,
    DIR_SOUTH = 2,
    DIR_WEST = 3
};

typedef struct {
    int32_t x, y, hp, score, turn, status;
} GameState;

static int32_t tile_at(int32_t x, int32_t y) {
    if (x == 3 && y == 3) return TILE_GOAL;
    if (x == 1 && y == 1) return TILE_TRAP;
    if (x == 2 && y == 1) return TILE_GOLD;
    if (x == 1 && y == 3) return TILE_GOLD;
    return TILE_FLOOR;
}

static int32_t clamp_axis(int32_t v) {
    if (v < 0) return 0;
    if (v >= GRID) return GRID - 1;
    return v;
}

static int32_t turn_phase(int32_t turn) { return turn % 4; }

static int32_t dir_for_turn(int32_t turn) {
    int32_t p = turn_phase(turn);
    if (p == 0 || p == 1) return DIR_EAST;
    return DIR_SOUTH;
}

static GameState new_game(void) {
    GameState g = {0, 0, START_HP, 0, 0, STATUS_PLAYING};
    return g;
}

static int32_t is_playing(GameState game) {
    return game.status == STATUS_PLAYING ? 1 : 0;
}

static GameState copy_game(int32_t x, int32_t y, int32_t hp, int32_t score, int32_t turn, int32_t status) {
    GameState g = {x, y, hp, score, turn, status};
    return g;
}

static int32_t trap_hp(int32_t hp) {
    int32_t h = hp - TRAP_DAMAGE;
    return h <= 0 ? 0 : h;
}

static int32_t trap_status(int32_t hp, int32_t playing) {
    int32_t h = hp - TRAP_DAMAGE;
    return h <= 0 ? STATUS_LOST : playing;
}

static GameState apply_tile_at(int32_t sx, int32_t sy, int32_t shp, int32_t sscore, int32_t sturn, int32_t sstatus, int32_t t) {
    switch (t) {
        case TILE_FLOOR: return copy_game(sx, sy, shp, sscore, sturn, sstatus);
        case TILE_GOLD: return copy_game(sx, sy, shp, sscore + GOLD_VALUE, sturn, sstatus);
        case TILE_GOAL: return copy_game(sx, sy, shp, sscore + GOAL_BONUS, sturn, STATUS_WON);
        case TILE_TRAP: return copy_game(sx, sy, trap_hp(shp), sscore, sturn, trap_status(shp, sstatus));
        default: return copy_game(sx, sy, shp, sscore, sturn, sstatus);
    }
}

static GameState advance_parts(int32_t sx, int32_t sy, int32_t shp, int32_t sscore, int32_t sturn, int32_t sstatus, int32_t dx, int32_t dy) {
    int32_t nx = clamp_axis(sx + dx);
    int32_t ny = clamp_axis(sy + dy);
    return apply_tile_at(nx, ny, shp, sscore, sturn + 1, sstatus, tile_at(nx, ny));
}

static GameState move_player(GameState game, int32_t d) {
    int32_t sx = game.x, sy = game.y;
    int32_t shp = game.hp, sscore = game.score;
    int32_t sturn = game.turn, sstatus = game.status;
    switch (d) {
        case DIR_EAST: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
        case DIR_WEST: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
        case DIR_NORTH: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
        case DIR_SOUTH: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
        default: return game;
    }
}

static GameState step_turn(GameState game) {
    int32_t sx = game.x, sy = game.y;
    int32_t shp = game.hp, sscore = game.score;
    int32_t sturn = game.turn, sstatus = game.status;
    if (sstatus == STATUS_PLAYING) {
        switch (dir_for_turn(sturn)) {
            case DIR_EAST: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
            case DIR_WEST: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
            case DIR_NORTH: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
            case DIR_SOUTH: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
        }
    }
    return copy_game(sx, sy, shp, sscore, sturn, sstatus);
}

static int32_t run_dungeon(void) {
    GameState game = new_game();
    while (is_playing(game) && game.turn < MAX_TURNS) {
        game = step_turn(game);
    }
    if (!is_playing(game)) return game.score;
    GameState lost = copy_game(game.x, game.y, game.hp, game.score, game.turn, STATUS_LOST);
    return lost.score;
}

static int32_t outcome_code(GameState game) { return game.status; }

int main(void) {
    printf("Dungeon Steps\n");
    printf("%d\n", run_dungeon());
    GameState g0 = new_game();
    GameState g1 = move_player(g0, DIR_EAST);
    printf("%d\n", outcome_code(g1));
    int32_t banner = 0;
    for (int32_t i = 0; i < 3; i++) banner += i;
    printf("%d\n", banner);
    return 0;
}
