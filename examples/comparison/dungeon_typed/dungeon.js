// Same logic as App/NyraApp (Dungeon Steps) for fair runtime comparison.

const GRID = 4;
const START_HP = 100;
const MAX_TURNS = 24;
const TRAP_DAMAGE = 25;
const GOLD_VALUE = 15;
const GOAL_BONUS = 50;
const APP_TITLE = "Dungeon Steps";
const STATUS_PLAYING = 0;
const STATUS_WON = 1;
const STATUS_LOST = 2;

const Tile = { Floor: 0, Trap: 1, Gold: 2, Goal: 3 };
const Dir = { North: 0, East: 1, South: 2, West: 3 };

function tileAt(x, y) {
  if (x === 3 && y === 3) return Tile.Goal;
  if (x === 1 && y === 1) return Tile.Trap;
  if (x === 2 && y === 1) return Tile.Gold;
  if (x === 1 && y === 3) return Tile.Gold;
  return Tile.Floor;
}

function clampAxis(v) {
  if (v < 0) return 0;
  if (v >= GRID) return GRID - 1;
  return v;
}

function turnPhase(turn) {
  return turn % 4;
}

function dirForTurn(turn) {
  const phase = turnPhase(turn);
  if (phase === 0 || phase === 1) return Dir.East;
  return Dir.South;
}

function newGame() {
  return { x: 0, y: 0, hp: START_HP, score: 0, turn: 0, status: STATUS_PLAYING };
}

function isPlaying(game) {
  return game.status === STATUS_PLAYING ? 1 : 0;
}

function copyGame(x, y, hp, score, turn, status) {
  return { x, y, hp, score, turn, status };
}

function trapHp(hp) {
  const h = hp - TRAP_DAMAGE;
  return h <= 0 ? 0 : h;
}

function trapStatus(hp, playing) {
  const h = hp - TRAP_DAMAGE;
  return h <= 0 ? STATUS_LOST : playing;
}

function applyTileAt(sx, sy, shp, sscore, sturn, sstatus, tile) {
  switch (tile) {
    case Tile.Floor:
      return copyGame(sx, sy, shp, sscore, sturn, sstatus);
    case Tile.Gold:
      return copyGame(sx, sy, shp, sscore + GOLD_VALUE, sturn, sstatus);
    case Tile.Goal:
      return copyGame(sx, sy, shp, sscore + GOAL_BONUS, sturn, STATUS_WON);
    case Tile.Trap:
      return copyGame(sx, sy, trapHp(shp), sscore, sturn, trapStatus(shp, sstatus));
    default:
      return copyGame(sx, sy, shp, sscore, sturn, sstatus);
  }
}

function advanceParts(sx, sy, shp, sscore, sturn, sstatus, dx, dy) {
  const nx = clampAxis(sx + dx);
  const ny = clampAxis(sy + dy);
  return applyTileAt(nx, ny, shp, sscore, sturn + 1, sstatus, tileAt(nx, ny));
}

function movePlayer(game, d) {
  const { x: sx, y: sy, hp: shp, score: sscore, turn: sturn, status: sstatus } = game;
  switch (d) {
    case Dir.East:
      return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
    case Dir.West:
      return advanceParts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
    case Dir.North:
      return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
    case Dir.South:
      return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
    default:
      return game;
  }
}

function stepTurn(game) {
  const { x: sx, y: sy, hp: shp, score: sscore, turn: sturn, status: sstatus } = game;
  if (sstatus === STATUS_PLAYING) {
    switch (dirForTurn(sturn)) {
      case Dir.East:
        return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 1, 0);
      case Dir.West:
        return advanceParts(sx, sy, shp, sscore, sturn, sstatus, -1, 0);
      case Dir.North:
        return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, -1);
      case Dir.South:
        return advanceParts(sx, sy, shp, sscore, sturn, sstatus, 0, 1);
    }
  }
  return copyGame(sx, sy, shp, sscore, sturn, sstatus);
}

function runDungeon() {
  let game = newGame();
  while (isPlaying(game) !== 0 && game.turn < MAX_TURNS) {
    game = stepTurn(game);
  }
  if (isPlaying(game) === 0) {
    return game.score;
  }
  const lost = copyGame(game.x, game.y, game.hp, game.score, game.turn, STATUS_LOST);
  return lost.score;
}

function outcomeCode(game) {
  return game.status;
}

function main() {
  console.log(APP_TITLE);
  console.log(runDungeon());
  const g0 = newGame();
  const g1 = movePlayer(g0, Dir.East);
  console.log(outcomeCode(g1));
  let banner = 0;
  for (let i = 0; i < 3; i++) {
    banner = banner + i;
  }
  console.log(banner);
}

main();
