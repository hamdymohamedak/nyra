# Apps — Nyra language smoke tests

Small programs that expose problems in the **parser**, **type checker**, **loops**, **functions**, **memory**, and **stdlib** before building larger apps (e.g. GhostTerm).

If these fail, fix the language/stdlib first.

All apps under `Basics/` and `FileSystem/` are independent **`nyra pkg init` projects** (own `nyra.mod`, `main.ny`, `src/`). They use the **auto-prelude** stdlib (no `import "stdlib/…"`) and only import project-local files. This mirrors how external developers use Nyra.

## Phase 1 — Language basics (algorithms)

| App | Tests | Run |
|-----|-------|-----|
| `Basics/Calculator/` | functions, structs, arithmetic | `cd Basics/Calculator && nyra run .` |
| `Basics/FizzBuzz/` | loops, `%`, conditionals | `cd Basics/FizzBuzz && nyra run .` |
| `Basics/Fibonacci/` | loops, functions, accumulation | `cd Basics/Fibonacci && nyra run .` |
| `Basics/Factorial/` | recursion + loops, functions | `cd Basics/Factorial && nyra run .` |
| `Basics/Prime_Numbers/` | nested loops, functions | `cd Basics/Prime_Numbers && nyra run .` |
| `Basics/Binary_Search/` | arrays as params, while, indexing | `cd Basics/Binary_Search && nyra run .` |
| `Basics/Sorting/` | array mutation, nested loops, `.sort()` | `cd Basics/Sorting && nyra run .` |
| `Basics/Hash_Map/` | stdlib map, structs, methods | `cd Basics/Hash_Map && nyra run .` |
| `Basics/Linked_List/` | ptr vec, structs, memory | `cd Basics/Linked_List && nyra run .` |

## Phase 1b — Basics CLI suite (language feature coverage)

Each project exercises **variables, loops, functions, structs, enums, arrays, generics, and memory** through real CLI tools.

| App | What it does | Run |
|-----|--------------|-----|
| `Basics/HelloWorld/` | variables, print | `cd Basics/HelloWorld && nyra run .` |
| `Basics/Calculator/` | structs, functions, CLI args | `./target/debug/main 10 + 5` |
| `Basics/TodoCLI/` | loops, structs, file I/O | `cd Basics/TodoCLI && nyra run .` |
| `Basics/UnitConverter/` | enums, `match`, functions | `./target/debug/main 1000 m km` |
| `Basics/Stopwatch/` | `instant_now`, ptr vec (laps) | `cd Basics/Stopwatch && nyra run .` |
| `Basics/Timer/` | `sleep_ms`, countdown loop | `./target/debug/main 3` |
| `Basics/PasswordGenerator/` | generics, `random_range` | `./target/debug/main 16 --symbols` |
| `Basics/RandomQuoteGenerator/` | `StrVec`, loops | `cd Basics/RandomQuoteGenerator && nyra run .` |
| `Basics/Base64/` | stdlib `base64_encode` / `base64_decode` (prelude) | `./target/debug/main encode hello` |
| `Basics/SHA256/` | stdlib `sha256()` (prelude) | `./target/debug/main hello` |
| `Basics/AES/` | stdlib `aes_encrypt` / `aes_decrypt` | `./target/debug/main enc <32-byte-key> text` |
| `Basics/UuidGenerator/` | stdlib `UUID_v4()` (prelude) | `./target/debug/main 3` |
| `Basics/JsonPrettyPrinter/` | structs, string scan | `./target/debug/main file.json` |
| `Basics/CsvReader/` | structs, `StrVec`, template strings | `./target/debug/main sample.csv` |
| `Basics/IniParser/` | sections, key=value parse | `./target/debug/main sample.ini` |
| `Basics/MarkdownToHtml/` | enums, `match`, inline transform | `./target/debug/main sample.md` |
| `Basics/UrlParser/` | struct fields, `str_to_i32` | `./target/debug/main 'https://host/path?q=1'` |

Build all Basics CLI suite apps:

```bash
for d in HelloWorld Calculator TodoCLI UnitConverter Stopwatch Timer PasswordGenerator \
         RandomQuoteGenerator Base64 JsonPrettyPrinter CsvReader IniParser MarkdownToHtml \
         UrlParser UuidGenerator; do
  (cd "Basics/$d" && nyra build .) || exit 1
done
```

## Phase 3 — Classic CLI tools (Nyra rewrites)

Reimplementations of familiar Unix tools under `FileSystem/` — each directory is an **independent `nyra pkg init` project** (own `nyra.mod`, `main.ny`, `src/`). Apps use the **auto-prelude** stdlib (no `import "stdlib/…"`) and only import project-local files (`import "src/cat.ny"`, `import "cli.ny"`). This mirrors how external developers use Nyra, away from compiler/stdlib source trees.

| App | What it does | Run |
|-----|--------------|-----|
| `FileSystem/cat/` | Concatenate files (or stdin with `-`) | `./target/debug/main file.txt` |
| `FileSystem/cp/` | Copy files | `./target/debug/main src dst` |
| `FileSystem/mv/` | Move / rename files | `./target/debug/main src dst` |
| `FileSystem/rm/` | Remove files (`-r` for directories) | `./target/debug/main [-r] file` |
| `FileSystem/touch/` | Create or update files | `./target/debug/main file` |
| `FileSystem/ls/` | List directory (`-l` size column) | `./target/debug/main [dir]` |
| `FileSystem/tree/` | Directory tree view | `./target/debug/main [dir]` |
| `FileSystem/find/` | Find files by name substring | `./target/debug/main dir pattern` |
| `FileSystem/grep/` | Search lines (`-i`, `-n`, `-v`) | `./target/debug/main pattern file` |
| `FileSystem/wc/` | Line/word/char count (`-l`, `-w`, `-c`) | `./target/debug/main file` |
| `FileSystem/head/` | First 10 lines | `./target/debug/main file` |
| `FileSystem/tail/` | Last 10 lines | `./target/debug/main file` |
| `FileSystem/diff/` | Compare two files | `./target/debug/main a b` |
| `FileSystem/zip/` | Create NyCompress `.nyc` archive | `./target/debug/main arc.nyc file` |
| `FileSystem/unzip/` | Extract gzip archive | `./target/debug/main arc.gz out` |
| `FileSystem/tar/` | Nyra archive create/extract (`-c`/`-x`) | `./target/debug/main -c arc.nyt file` |
| `FileSystem/curl/` | HTTP GET (`-I` for HEAD) | `./target/debug/main https://example.com` |
| `FileSystem/explorer/` | Interactive file browser | `./target/debug/main [start-dir]` |

Build all FileSystem CLI rewrites:

```bash
for d in cat cp mv rm touch ls tree find grep wc head tail diff zip unzip tar curl explorer; do
  (cd "FileSystem/$d" && nyra build .) || exit 1
done
```

## Phase 2 — Real console programs

Programs people actually run — files, network, memory, performance.

| App | What it does | Run |
|-----|--------------|-----|
| `Basics/MiniEdit/` | Simple text editor (`:list`, `:save`, `:edit`) | `cd Basics/MiniEdit && nyra run .` |
| `Basics/FileCopy/` | Chunked file copy (`copy_file`) | `cd Basics/FileCopy && nyra run .` |
| `Basics/NyCompress/` | RLE compress / decompress files | `cd Basics/NyCompress && nyra run .` |
| `Basics/MiniHTTP/` | HTTP/1.1 server (`/`, `/health`, `/echo`) | `cd Basics/MiniHTTP && nyra run .` |
| `Basics/NyChat/` | TCP chat (server + client) | `cd Basics/NyChat && nyra run .` |
| `Basics/TaskCLI/` | Task manager (persisted to `tasks.nyra.txt`) | `cd Basics/TaskCLI && nyra run .` |

Build all smoke + console apps:

```bash
for d in Calculator FizzBuzz Fibonacci Factorial Prime_Numbers Binary_Search Sorting Hash_Map Linked_List \
         MiniEdit NyCompress MiniHTTP NyChat TaskCLI; do
  (cd "Basics/$d" && nyra build .) || exit 1
done
```

Test HTTP (server in one terminal):

```bash
curl -s http://127.0.0.1:8080/health
curl -s -X POST -d 'hello' http://127.0.0.1:8080/echo
```

## Phase 6 — Graphics (raylib windowing)

Tests **performance**, **memory**, and **windowing** via [raylib](https://www.raylib.com/). Each project is an independent `nyra pkg init` package under `Graphics/` with `vendor/bindings/raylib.ny`, `link raylib`, and Homebrew lib path in `nyra.mod`. Shared helpers: `Graphics/shared/colors.ny` (`Gfx_color`) and `Graphics/shared/window.ny` (`Gfx_window_open`, `Gfx_frame_begin`, …).

**Prerequisite:** `brew install raylib` (paths assume `/opt/homebrew/opt/raylib/lib` on Apple Silicon).

**Skip (already exists):** Terminal Emulator → `Basics/GhostTerm/`

| App | What it does | Run |
|-----|--------------|-----|
| `Graphics/ImageViewer/` | Texture load, `DrawTextureEx` zoom, optional file arg | `cd Graphics/ImageViewer && nyra run . [image.png]` |
| `Graphics/Paint/` | Mouse drawing, stroke buffer (64 segments) | `cd Graphics/Paint && nyra run .` |
| `Graphics/PhotoEditor/` | Image tint / brightness toggle | `cd Graphics/PhotoEditor && nyra run .` |
| `Graphics/RayTracer/` | CPU ray-sphere hit test + `DrawPixel` | `cd Graphics/RayTracer && nyra run .` |
| `Graphics/Renderer2D/` | Rectangles, circles, lines, text | `cd Graphics/Renderer2D && nyra run .` |
| `Graphics/SpriteEngine/` | Texture sprite bounce | `cd Graphics/SpriteEngine && nyra run .` |
| `Graphics/ParticleEngine/` | 16-particle pool, array memory | `cd Graphics/ParticleEngine && nyra run .` |
| `Graphics/FontRenderer/` | Multi-size `DrawText` demo | `cd Graphics/FontRenderer && nyra run .` |
| `Graphics/PDFViewer/` | Scrollable text pages MVP (`sample.txt`) | `cd Graphics/PDFViewer && nyra run .` |

Build all Graphics apps:

```bash
for d in ImageViewer Paint PhotoEditor RayTracer Renderer2D SpriteEngine ParticleEngine FontRenderer PDFViewer; do
  (cd "Graphics/$d" && nyra build .) || exit 1
done
```

**Modern Nyra:** Graphics use `@root` imports, `0xff`, `[0; N]`. String `==`/`!=` compare content via `str_cmp`. Struct fields with `[0; N]` and `mut` struct params work for array mutation. See `tests/nyra/language_improvements_test.ny`.

## Phase 8 — GUI apps (raylib widgets)

Desktop GUI smoke tests under `GUI apps/` — hand-rolled buttons, text fields, and file browsers on raylib. See [`GUI apps/plan.md`](GUI%20apps/plan.md) for gaps and build commands.

```bash
BASE="Apps/GUI apps"
for d in CalculatorGUI TextEditor MusicPlayer FileManager NoteApp Paint SimpleIDE; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```


TCP/HTTP/WebSocket/mail/protocol probes under `Networking apps/` — each directory is an independent `nyra pkg init` project. See [`Networking apps/plan.md`](Networking%20apps/plan.md) for gaps and build commands.

```bash
BASE="Apps/Networking apps"
for d in HTTPServer HTTPClient RestAPI WebSocketServer ChatServer ChatClient \
         FtpClient DnsLookup Ping PortScanner SmtpClient TcpProxy ReverseProxy CdnCache; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Phase 8 — Games (raylib + terminal)

Classic game reimplementations under `Games/` — each directory is an independent `nyra pkg init` project. See [`Games/plan.md`](Games/plan.md) for gaps and build commands.

```bash
BASE="Apps/Games"
for d in Pong Snake Tetris Minesweeper Sudoku Chess Breakout FlappyBird DoomClone MinecraftClone; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Phase 9 — Database apps

Storage engine and cache probes under `databases apps/` — each directory is an independent `nyra pkg init` project. See [`databases apps/plan.md`](databases%20apps/plan.md) for gaps and build commands.

```bash
BASE="Apps/databases apps"
for d in SQLiteClone KeyValueDatabase RedisClone LsmTree BTreeDatabase QueryParser CacheSystem; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Phase 10 — Dev toolchain apps

Developer-tool probes under `dev apps/` — Linter, Package Manager, DocGen, Test Runner, Benchmark, Fuzzer, Profiler, Memory Leak Detector. Each is an independent `nyra pkg init` project. See [`dev apps/plan.md`](dev%20apps/plan.md) for gaps and build commands.

```bash
BASE="Apps/dev apps"
for d in Linter PackageManager DocumentationGenerator TestRunner BenchmarkTool Fuzzer Profiler MemoryLeakDetector; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Phase 10 — Compiler apps

Parser, lexer, regex, and AST probes under `Compiler apps/` — each directory is an independent `nyra pkg init` project. See [`Compiler apps/plan.md`](Compiler%20apps/plan.md) for gaps and build commands.

```bash
BASE="Apps/Compiler apps"
for d in JSONParser TOMLParser XMLParser YAMLParser RegexEngine MarkdownParser Lexer Parser ASTVisualizer; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

