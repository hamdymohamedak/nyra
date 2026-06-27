// Same logic as App/NyraApp (Dungeon Steps) for fair runtime comparison.

public class Dungeon {
    private static final int GRID = 4;
    private static final int START_HP = 100;
    private static final int MAX_TURNS = 24;
    private static final int TRAP_DAMAGE = 25;
    private static final int GOLD_VALUE = 15;
    private static final int GOAL_BONUS = 50;
    private static final String APP_TITLE = "Dungeon Steps";
    private static final int STATUS_PLAYING = 0;
    private static final int STATUS_WON = 1;
    private static final int STATUS_LOST = 2;

    private enum Tile { Floor, Trap, Gold, Goal }
    private enum Dir { North, East, South, West }

    private static final class GameState {
        final int x, y, hp, score, turn, status;
        GameState(int x, int y, int hp, int score, int turn, int status) {
            this.x = x;
            this.y = y;
            this.hp = hp;
            this.score = score;
            this.turn = turn;
            this.status = status;
        }
    }

    private static Tile tileAt(int x, int y) {
        if (x == 3 && y == 3) return Tile.Goal;
        if (x == 1 && y == 1) return Tile.Trap;
        if (x == 2 && y == 1) return Tile.Gold;
        if (x == 1 && y == 3) return Tile.Gold;
        return Tile.Floor;
    }

    private static int clampAxis(int v) {
        if (v < 0) return 0;
        if (v >= GRID) return GRID - 1;
        return v;
    }

    private static int turnPhase(int turn) {
        return turn % 4;
    }

    private static Dir dirForTurn(int turn) {
        int phase = turnPhase(turn);
        if (phase == 0 || phase == 1) return Dir.East;
        return Dir.South;
    }

    private static GameState newGame() {
        return new GameState(0, 0, START_HP, 0, 0, STATUS_PLAYING);
    }

    private static int isPlaying(GameState game) {
        return game.status == STATUS_PLAYING ? 1 : 0;
    }

    private static GameState copyGame(int x, int y, int hp, int score, int turn, int status) {
        return new GameState(x, y, hp, score, turn, status);
    }

    private static int trapHp(int hp) {
        int h = hp - TRAP_DAMAGE;
        return h <= 0 ? 0 : h;
    }

    private static int trapStatus(int hp, int playing) {
        int h = hp - TRAP_DAMAGE;
        return h <= 0 ? STATUS_LOST : playing;
    }

    private static GameState applyTileAt(int sx, int sy, int shp, int sscore, int sturn, int sstatus, Tile tile) {
        switch (tile) {
            case Floor: return copyGame(sx, sy, shp, sscore, sturn, sstatus);
            case Gold: return copyGame(sx, sy, shp, sscore + GOLD_VALUE, sturn, sstatus);
            case Goal: return copyGame(sx, sy, shp, sscore + GOAL_BONUS, sturn, STATUS_WON);
            case Trap: return copyGame(sx, sy, trapHp(shp), sscore, sturn, trapStatus(shp, sstatus));
            default: return copyGame(sx, sy, shp, sscore, sturn, sstatus);
        }
    }

    private static GameState advanceParts(int sx, int sy, int shp, int sscore, int sturn, int sstatus, int dx, int dy) {
        int nx = clampAxis(sx + dx);
        int ny = clampAxis(sy + dy);
        return applyTileAt(nx, ny, shp, sscore, sturn + 1, sstatus, tileAt(nx, ny));
    }

    private static GameState movePlayer(GameState game, Dir d) {
        int sx = game.x, sy = game.y, shp = game.hp, sscore = game.score, sturn = game.turn, sstatus = game.status;
        switch (d) {
            case East: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
            case West: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
            case North: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
            case South: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
            default: return game;
        }
    }

    private static GameState stepTurn(GameState game) {
        int sx = game.x, sy = game.y, shp = game.hp, sscore = game.score, sturn = game.turn, sstatus = game.status;
        if (sstatus == STATUS_PLAYING) {
            switch (dirForTurn(sturn)) {
                case East: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
                case West: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
                case North: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
                case South: return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
            }
        }
        return copyGame(sx, sy, shp, sscore, sturn, sstatus);
    }

    private static int runDungeon() {
        GameState game = newGame();
        while (isPlaying(game) != 0 && game.turn < MAX_TURNS) {
            game = stepTurn(game);
        }
        if (isPlaying(game) == 0) {
            return game.score;
        }
        GameState lost = copyGame(game.x, game.y, game.hp, game.score, game.turn, STATUS_LOST);
        return lost.score;
    }

    private static int outcomeCode(GameState game) {
        return game.status;
    }

    public static void main(String[] args) {
        System.out.println(APP_TITLE);
        System.out.println(runDungeon());
        GameState g0 = newGame();
        GameState g1 = movePlayer(g0, Dir.East);
        System.out.println(outcomeCode(g1));
        int banner = 0;
        for (int i = 0; i < 3; i++) {
            banner += i;
        }
        System.out.println(banner);
    }
}
