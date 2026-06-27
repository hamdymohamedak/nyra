# Nyra C Bindgen (`nyra bind c`)

Automatic **C header → Nyra `extern fn`** bindings via **libclang** (same AST engine as Clang/LLVM).

> Call millions of C libraries with zero manual FFI — regenerate when headers change.

## Quick start — `nyra pkg c` (recommended)

One command per system library: install (Homebrew/apt), full bindgen, `nyra.mod` link lines, manifest.

```bash
nyra pkg init && cd myapp

nyra pkg c add raylib     # graphics / games
nyra pkg c add zlib       # compression
nyra pkg c add sqlite3    # database
nyra pkg c add sdl2       # 2D / input

nyra pkg c list           # installed in this project
nyra pkg c remove raylib  # delete bindings + unlink nyra.mod

import "vendor/bindings/raylib.ny"
```

**Catalog:** `raylib`, `zlib`, `sqlite3` (alias `sqlite`), `sdl2`.

**Flags:** `--path DIR`, `--no-install` (skip `brew install`).

**Manifest:** `vendor/bindings/c-libs.toml` — used by `remove`.

**Prerequisites:** `brew install llvm` or `nyra toolchain install` (libclang).

## Manual bind (any header)

```bash
nyra bind c /path/to/header.h --lib foo --update-mod
nyra pkg bind c vendor/api.h --lib mylib --update-mod
nyra bind c vendor/api.h --stdout --prefix mylib_
```

Default: **all bindable functions** in `vendor/bindings/{stem}.ny`. C params that are Nyra keywords become `in_`, `type_`, etc. Optional `--export SYM` to shrink.

## Generated output

```ny
struct Point repr(C) {
    x: i32
    y: i32
}

extern fn make_point(x: i32, y: i32) -> Point
extern fn sqlite3_open(filename: string, ppDb: ptr) -> i32
```

With `--update-mod`, `nyra.mod` gets:

```text
link sqlite3
```

## CLI reference

```text
nyra pkg c add NAME [--path DIR] [--no-install]
nyra pkg c remove NAME [--path DIR]
nyra pkg c list [--path DIR]

nyra bind c HEADER [options]
nyra pkg bind c HEADER [options]

  --lib NAME           nyra.mod: link NAME  (repeatable)
  -I, --include DIR    clang -I path       (repeatable)
  -D, --define MACRO   clang -D            (repeatable)
  -o, --output FILE    output .ny path
  --prefix PREFIX      only functions starting with PREFIX
  --export SYM         optional shrink filter (default: all symbols)
  --shim               experimental C shims for complex signatures
  --no-shim            disable shims
  --update-mod         append link / link-source lines to nyra.mod
  --stdout             print bindings, do not write file
  --project DIR        project root (nyra bind c)
  --path DIR           project root (nyra pkg bind c)
```

## Type mapping (C → Nyra FFI)

| C | Nyra |
|---|------|
| `char` / `signed char` | `i8` |
| `unsigned char` | `u8` |
| `short` | `i16` |
| `unsigned short` | `u16` |
| `int` | `i32` |
| `unsigned` | `u32` |
| `long` / `long long` | `i64` |
| `unsigned long` / `unsigned long long` | `u64` |
| `float` / `double` | `f64` |
| `_Bool` / `bool` | `bool` |
| `const char *` | `string` |
| complete struct (ABI-safe fields) | `repr(C) struct Name { … }` |
| C enum | `i32` |
| pointers, fn pointers | `ptr` |

Unsupported signatures are skipped unless **auto shims** (`--shim`, experimental). ~25 Raylib symbols need shims or manual wrappers.

## Regenerate after header updates

```bash
nyra pkg c add raylib    # refreshes bindings + manifest
# or
nyra pkg bind c vendor/foo.h --lib foo --update-mod
```

## Examples

- `examples/c_raylib/` — Raylib window + game loop
- `examples/c_bindgen/` — custom C + `link-source`

## Architecture

```
header.h  →  libclang AST  →  nyra-c-bindgen  →  vendor/bindings/*.ny
                                              →  vendor/bindings/shim.c (optional, --shim)
                                              →  nyra.mod link lines
                                              →  vendor/bindings/c-libs.toml (nyra pkg c)
```

Crate: `c-bindgen/` · CLI: `nyra pkg c` / `nyra bind c` / `nyra pkg bind c`

See also [native-cc.md](native-cc.md) · [bindings.md](bindings.md) · `webDocs/c-bindgen.html`
