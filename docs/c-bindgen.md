# C libraries in Nyra

Nyra does **not** install C libraries. Your system package manager does that.
Nyra only **discovers**, **binds**, and **links** them into your project.

```text
Homebrew / apt / dnf / pacman   →  install headers + .so/.dylib
nyra bind <lib>                 →  bindings + nyra.mod link lines
```

## Recommended flow

```bash
# 1. Install with your OS package manager
brew install raylib          # macOS
# sudo apt install libraylib-dev
# sudo dnf install raylib-devel
# sudo pacman -S raylib

# 2. Bind into the Nyra project
nyra bind raylib
```

Same idea via `nyra pkg add raylib` (alias).

**What Nyra does**

1. Find the library (`pkg-config`, Homebrew prefix, `/usr/include`, …)
2. Generate `vendor/bindings/raylib.ny`
3. Add `link raylib` (and `link -L …`) to `nyra.mod`

```ny
import "vendor/bindings/raylib.ny"
```

### If the library is missing

```bash
nyra bind raylib
```

```text
raylib is not installed.

Detected package manager: Homebrew

Run:
  brew install raylib

Continue? [Y/n]
```

`-y` runs the install command then binds:

```bash
nyra bind raylib -y
```

`--no-install` never runs brew/apt — fail if missing.

## Registry (package names only)

Slim manifests in [`registry/c/`](../registry/c/) map a Nyra name to each PM:

```toml
name = "raylib"
headers = ["raylib.h"]
libs = ["raylib"]
pkg_config = "raylib"
brew = "raylib"
apt = "libraylib-dev"
dnf = "raylib-devel"
pacman = "raylib"
```

Known names: **310+** built-ins including **AI/ML**, **RPC/data** (`grpc`, `arrow`, `duckdb`), **observability** (`opentelemetry-cpp`, `prometheus-cpp`), **Wasm** (`wasmtime`, `wasmer`, `wamr`), auth/cloud, messaging, robotics, and classic networks/games/GUI/media/science. See [`registry/c/`](../registry/c/) or `nyra pkg list`. Validate with `python3 make/py/test_c_registry.py --bind`.

### C++ libraries (`cxx = true`)

Entries such as `sentencepiece`, `protobuf`, `eigen`, and `libtorch` set `cxx = true`. Then `nyra bind`:

1. Parses headers as **C++17** (`-x c++ -stdlib=libc++`)
2. Emits `vendor/bindings/shim.cpp` with stable **`extern "C"`** wrappers (free functions + simple public methods as `Class_method(self, …)`)
3. Adds `link-source vendor/bindings/shim.cpp` and `link c++` (macOS) / `link stdc++` (Linux)
4. Compiles the shim with **`clang++`** at `nyra build` time

Skipped for now (not FFI-safe yet): STL by-value (`std::string`, `std::vector`), references, private/virtual methods, templates. Prefer C APIs when a library ships both.

Overrides: `~/.nyra/registry/c/*.toml` · `$NYRA_C_REGISTRY` · `./registry/c/`

## Manual bind (not on any package manager)

Any header on disk:

```bash
nyra bind c /path/to/mylib.h --lib mylib --update-mod
```

Optional: `-I /path/to/include` · `-o vendor/bindings/mylib.ny`

Then import:

```ny
import "vendor/bindings/mylib.ny"
```

## GitHub / git URL

```bash
nyra pkg add https://github.com/someone/cool-library
```

Clones into `vendor/c-src/`, looks for `nyra.toml` or common build files, then binds.
If discovery fails, use the manual command above on the cloned header.

## Type mapping (C → Nyra)

| C | Nyra |
|---|------|
| `float` | `f32` |
| `double` | `f64` |
| `int` | `i32` |
| `const char *` | `string` |
| pointers | `ptr` |
| struct (safe fields) | `repr(C) struct …` |

Needs **libclang** for bindgen. The Nyra installer bundles it under `~/.nyra/lib/llvm` by default (`nyra toolchain install` / `install.sh`). You do **not** need a separate `brew install llvm` just to use C libraries — only install the C package itself (e.g. `brew install zlib`).

If bindgen cannot find libclang: `nyra toolchain install --download`.

## Examples

- `examples/c_raylib/` — Raylib window
- `examples/c_bindgen/` — custom C + `link-source`

See also [native-cc.md](native-cc.md) · [bindings.md](bindings.md) · `webDocs/c-bindgen.html`
