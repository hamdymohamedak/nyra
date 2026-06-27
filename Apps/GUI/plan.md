# GUI apps — Nyra language smoke tests

Desktop-style GUI programs built with **raylib** windowing and hand-rolled widgets. Each directory is an independent **`nyra pkg init` project** (own `nyra.mod`, `main.ny`, `src/`). Shared helpers live in `shared/` (`colors.ny`, `window.ny`, `widgets.ny`).

**Prerequisite:** `brew install raylib` (paths assume `/opt/homebrew/opt/raylib/lib` on Apple Silicon).

## Projects

| App | What it does | Run |
|-----|--------------|-----|
| `CalculatorGUI/` | Button-grid calculator (+ − × ÷) | `cd CalculatorGUI && nyra run .` |
| `TextEditor/` | Type + Ctrl+S save to file | `nyra run . [file.txt]` |
| `MusicPlayer/` | Playlist UI + `LoadWave` probe | `nyra run . [music-folder]` |
| `FileManager/` | Browse dirs, preview file text | `nyra run . [start-dir]` |
| `NoteApp/` | Single-note pad persisted to `notes.txt` | `cd NoteApp && nyra run .` |
| `Paint/` | Mouse drawing canvas | `cd Paint && nyra run .` |
| `SimpleIDE/` | Sidebar `.ny` files + editor + save | `nyra run . [project-dir]` |

Build all:

```bash
BASE="Apps/GUI apps"
for d in CalculatorGUI TextEditor MusicPlayer FileManager NoteApp Paint SimpleIDE; do
  (cd "$BASE/$d" && nyra build .) || exit 1
done
```

## Language / stdlib gaps discovered

Most gaps from the initial smoke pass are **resolved in v1.16.0** (see `CHANGELOG.md` and `webDocs/changelog.html`). Remaining limitations are called out below.

| Gap | Status | Resolution |
|-----|--------|------------|
| No native GUI toolkit | **Open** | `stdlib/gui/` + `shared/widgets.ny` (raylib draw + hit tests); no OS-native widgets |
| `Sound` / `Music` skipped by bindgen | **Fixed** | Nested struct parsing in `c-bindgen`; `LoadMusicStream` works in MusicPlayer |
| No `raygui` bindings | **Fixed** v1.19.0 — `stdlib/gui/raygui.ny` + catalog entry |
| No `char_from_code` | **Fixed** | `char_from_code(i32) -> string` in `stdlib/strings.ny` |
| No scrollable text view | **Fixed** | `ScrollState` + `Gui_text_area_draw_scrolled` |
| No file picker dialog | **Partial** | `FilePicker` in `stdlib/gui/picker.ny` (in-app browser; no native OS dialog) |
| No syntax highlighting | **Fixed** | `Syntax_line_kind` + `Gui_text_area_syntax_draw` |
| No `continue` in loops | **Fixed** | `continue` statement + PHI back-edge codegen |
| String building in hot paths | **Fixed** | `StringBuilder` in `stdlib/strings/builder.ny` |
| `list_dir` → newline string only | **Fixed** | `list_dir_entries(path) -> StrVec` |
| `bool` vs `int` in conditions | **Fixed** | Use `!WindowShouldClose()`; `bool`/`i32` compare allowed in typecheck |
| No `argv()` helper | **Fixed** | `argv()` in `stdlib/vec_str.ny` |
| No multi-line cursor | **Fixed** | `TextBuffer` with arrow-key cursor (`stdlib/gui/buffer.ny`) |
| Whole-file preview load | **Fixed** | `read_file_limit(path, max_bytes)` |

## Suggested follow-ups (lower priority)

1. Optional **`raygui`** bindings or richer `stdlib/gui/` widgets (text field, list box).
2. **Native file picker** (platform dialog FFI).
3. **Selection / clipboard** in `TextBuffer` (shift+arrows, copy/paste).

## Widget API (shared)

- `Gui_button_draw` / `Gui_button_clicked`
- `Gui_text_poll` — `GetCharPressed` + Backspace
- `Gui_text_area_draw` — wrapped line rendering
- `Gfx_window_open` / `Gfx_frame_begin` / `Gfx_frame_end`

See also: `Apps/Graphics/` (lower-level drawing demos), `Apps/plan.md`.
