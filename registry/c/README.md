# Nyra C library registry

Slim manifests for `nyra bind <name>` / `nyra pkg add <name>`.

Nyra is **not** a C package manager. These files only map names so Nyra can:

1. Suggest the right `brew` / `apt` / `dnf` / `pacman` install command
2. Find headers via `pkg-config` (or system include paths)
3. Generate bindings + `nyra.mod` link lines

```toml
name = "gsl"
description = "GNU Scientific Library"
headers = ["gsl/gsl_sf.h"]
libs = ["gsl", "gslcblas"]
pkg_config = "gsl"
brew = "gsl"
apt = "libgsl-dev"
pacman = "gsl"
dnf = "gsl-devel"
aliases = ["gnu-gsl"]
```

Header-only libs that live on GitHub (e.g. raygui):

```toml
name = "raygui"
headers = ["src/raygui.h"]
libs = ["raylib"]
brew = "raylib"
git = "https://github.com/raysan5/raygui.git"
depends = ["raylib"]
```

User overrides: `~/.nyra/registry/c/*.toml`

For GitHub C projects, prefer a root `nyra.toml`:

```toml
[c]
headers = ["include/cool.h"]
libraries = ["cool"]
include_dirs = ["include"]
```

If a library is **not** in any package manager and not in this registry:

```bash
nyra bind c /path/to/header.h --lib NAME --update-mod
```
