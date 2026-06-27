# Games — Nyra language smoke tests

Classic game reimplementations that expose gaps in **game loops**, **2D/3D graphics**, **grid algorithms**, **input**, **collision**, **random**, and **stdlib math** before building larger titles.

Each directory is an independent **`nyra pkg init` project** (own `nyra.mod`, `main.ny`, `src/`). Raylib games use `nyra pkg c add raylib`. Apps use the **auto-prelude** stdlib and only import project-local files plus `../../shared/`.

**Prerequisite (raylib games):** `brew install raylib` (paths assume `/opt/homebrew/opt/raylib/lib` on Apple Silicon).

## Projects

| App | Stack | What it tests | Run |
|-----|-------|---------------|-----|
| `Pong/` | raylib | game loop, `GetFrameTime`, paddle collision, score | `cd Pong && nyra run .` |
| `Snake/` | raylib | grid, growing body arrays, `random_range`, input | `cd Snake && nyra run .` |
| `Tetris/` | raylib | board grid, piece state, line clear (MVP) | `cd Tetris && nyra run .` |
| `Minesweeper/` | terminal | mine placement, adjacency, `stdin_read_line` | `cd Minesweeper && nyra run .` |
| `Sudoku/` | terminal | backtracking, 9×9 validation, `mut` array params | `cd Sudoku && nyra run .` |
| `Chess/` | raylib | 8×8 board render, mouse pick (move gen TBD) | `cd Chess && nyra run .` |
| `Breakout/` | raylib | brick array, AABB bounce, paddle | `cd Breakout && nyra run .` |
| `FlappyBird/` | raylib | gravity, pipe pool, collision reset | `cd FlappyBird && nyra run .` |
| `DoomClone/` | raylib | raycast MVP, `sin`/`cos` stdlib | `cd DoomClone && nyra run .` |
| `MinecraftClone/` | raylib | 8³ voxel chunk, isometric draw (3D TBD) | `cd MinecraftClone && nyra run .` |

Shared helpers: `shared/colors.ny`, `shared/window.ny`, `shared/grid_terminal.ny`, `shared/tetris.ny`, `shared/flood_fill.ny`.

Build all:

```bash
BASE="Apps/Games"
for d in Pong Snake Tetris Minesweeper Sudoku Chess Breakout FlappyBird DoomClone MinecraftClone; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Language / stdlib gaps — status (v1.22.0)

| Gap | Status | Notes |
|-----|--------|-------|
| No `sin` / `cos` / `atan2` in stdlib | **Fixed** | `stdlib/math.ny` + `rt_math.c`; compiler intrinsics avoid libc name clash |
| Array size `[0; COLS * ROWS]` invalid | **Fixed** | Const-folded repeat count expressions |
| Array params not inferred across fns | **Fixed** | Call-site `let` hints + signature refresh after typecheck |
| Negative literals in `const` arrays | **Fixed** | Const eval + codegen |
| `bool` vs `i32` compare | **Fixed** | Typecheck + codegen alignment |
| `DrawCircle` radius is `f64` | Workaround | Pass `8.0` (raylib binding) |
| `i32` paddle + `f64` `GetFrameTime()` | **Fixed** | `i32` → `f64` coercion in arithmetic |
| No `continue` in loops | **Fixed** | `while` latch block + PHI backedge patch |
| No raw keyboard without raylib | **Fixed** | `stdlib/terminal/raw.ny` (`stdin_read_key`) |
| `stdin_read_line` blocks | Partial | Raw key API exists; Minesweeper can migrate |
| No 2D dynamic arrays (`[][]`) | **Fixed** | `stdlib/games/grid2d.ny` — `Grid2D_i32` with resize |
| Piece rotation matrices (Tetris SRS) | **Helper** | `shared/tetris.ny` |
| No game audio | **Fixed** | `stdlib/games/audio.ny` + `raylib_audio.ny`; Games raylib `Music` ABI |
| No sprite atlas / texture packing | Open | Tooling / asset pipeline |
| Chess move generation | Open | Game logic, not language |
| Flood-fill reveal (Minesweeper) | **Helper** | `shared/flood_fill.ny` |
| True 3D voxel meshing | **Partial** | `VoxelChunk_i32` + `BeginMode3D(Camera3D)`; greedy mesh TBD |
| No fixed timestep helper | **Fixed** | `stdlib/time/fixed_step.ny` |
| No entity/component pattern | **Fixed** | `stdlib/games/ecs.ny` — `EcsWorld`, `EcsStore_i32`, `EcsStore_vec2` |
| `random_range` is `i32` only | **Fixed** | `random_f64()` in `stdlib/random.ny` |

Regression tests: `tests/nyra/games_gaps.ny`, `tests/nyra/games_stdlib.ny` (+ `.typed`). Examples: `examples/games/`.

## MVP status

These are **smoke-test MVPs**, not finished games. Each compiles and demonstrates core mechanics so compiler/stdlib gaps surface early. Expand toward full rules (Tetris rotation, Chess legality, Doom textures, Minecraft chunks) as the language matures.

## Remaining language gaps (shared with other Apps suites)

| Gap | Notes |
|-----|-------|
| No `i64_to_string()` | **Fixed** v1.17.0 | `i64_to_string` in `stdlib/strings.ny` |
| Struct inference across fn boundaries | **Fixed** v1.17.0 | `StructLiteral` / struct field call-site hints |
