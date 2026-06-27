// Same logic as App/NyraApp (Dungeon Steps) for fair runtime comparison.
#include <cstdint>
#include <iostream>

namespace {

constexpr int32_t GRID = 4;
constexpr int32_t START_HP = 100;
constexpr int32_t MAX_TURNS = 24;
constexpr int32_t TRAP_DAMAGE = 25;
constexpr int32_t GOLD_VALUE = 15;
constexpr int32_t GOAL_BONUS = 50;
constexpr int32_t STATUS_PLAYING = 0;
constexpr int32_t STATUS_WON = 1;
constexpr int32_t STATUS_LOST = 2;

enum class Tile { Floor, Trap, Gold, Goal };
enum class Dir { North, East, South, West };

struct GameState {
    int32_t x, y, hp, score, turn, status;
};

Tile tile_at(int32_t x, int32_t y) {
    if (x == 3 && y == 3) return Tile::Goal;
    if (x == 1 && y == 1) return Tile::Trap;
    if (x == 2 && y == 1) return Tile::Gold;
    if (x == 1 && y == 3) return Tile::Gold;
    return Tile::Floor;
}

int32_t clamp_axis(int32_t v) {
    if (v < 0) return 0;
    if (v >= GRID) return GRID - 1;
    return v;
}

int32_t turn_phase(int32_t turn) { return turn % 4; }

Dir dir_for_turn(int32_t turn) {
    int32_t p = turn_phase(turn);
    if (p == 0 || p == 1) return Dir::East;
    return Dir::South;
}

GameState new_game() { return {0, 0, START_HP, 0, 0, STATUS_PLAYING}; }

int32_t is_playing(GameState game) {
    return game.status == STATUS_PLAYING ? 1 : 0;
}

GameState copy_game(int32_t x, int32_t y, int32_t hp, int32_t score, int32_t turn, int32_t status) {
    return {x, y, hp, score, turn, status};
}

int32_t trap_hp(int32_t hp) {
    int32_t h = hp - TRAP_DAMAGE;
    return h <= 0 ? 0 : h;
}

int32_t trap_status(int32_t hp, int32_t playing) {
    int32_t h = hp - TRAP_DAMAGE;
    return h <= 0 ? STATUS_LOST : playing;
}

GameState apply_tile_at(int32_t sx, int32_t sy, int32_t shp, int32_t sscore, int32_t sturn, int32_t sstatus, Tile t) {
    switch (t) {
        case Tile::Floor: return copy_game(sx, sy, shp, sscore, sturn, sstatus);
        case Tile::Gold: return copy_game(sx, sy, shp, sscore + GOLD_VALUE, sturn, sstatus);
        case Tile::Goal: return copy_game(sx, sy, shp, sscore + GOAL_BONUS, sturn, STATUS_WON);
        case Tile::Trap: return copy_game(sx, sy, trap_hp(shp), sscore, sturn, trap_status(shp, sstatus));
    }
    return copy_game(sx, sy, shp, sscore, sturn, sstatus);
}

GameState advance_parts(int32_t sx, int32_t sy, int32_t shp, int32_t sscore, int32_t sturn, int32_t sstatus, int32_t dx, int32_t dy) {
    int32_t nx = clamp_axis(sx + dx);
    int32_t ny = clamp_axis(sy + dy);
    return apply_tile_at(nx, ny, shp, sscore, sturn + 1, sstatus, tile_at(nx, ny));
}

GameState move_player(GameState game, Dir d) {
    int32_t sx = game.x, sy = game.y;
    int32_t shp = game.hp, sscore = game.score;
    int32_t sturn = game.turn, sstatus = game.status;
    switch (d) {
        case Dir::East: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
        case Dir::West: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
        case Dir::North: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
        case Dir::South: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
    }
    return game;
}

GameState step_turn(GameState game) {
    int32_t sx = game.x, sy = game.y;
    int32_t shp = game.hp, sscore = game.score;
    int32_t sturn = game.turn, sstatus = game.status;
    if (sstatus == STATUS_PLAYING) {
        switch (dir_for_turn(sturn)) {
            case Dir::East: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
            case Dir::West: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
            case Dir::North: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
            case Dir::South: return advance_parts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
        }
    }
    return copy_game(sx, sy, shp, sscore, sturn, sstatus);
}

int32_t run_dungeon() {
    GameState game = new_game();
    while (is_playing(game) && game.turn < MAX_TURNS) {
        game = step_turn(game);
    }
    if (!is_playing(game)) return game.score;
    GameState lost = copy_game(game.x, game.y, game.hp, game.score, game.turn, STATUS_LOST);
    return lost.score;
}

int32_t outcome_code(GameState game) { return game.status; }

}  // namespace

int main() {
    std::cout << "Dungeon Steps\n";
    std::cout << run_dungeon() << '\n';
    GameState g0 = new_game();
    GameState g1 = move_player(g0, Dir::East);
    std::cout << outcome_code(g1) << '\n';
    int32_t banner = 0;
    for (int32_t i = 0; i < 3; i++) banner += i;
    std::cout << banner << '\n';
    return 0;
}
