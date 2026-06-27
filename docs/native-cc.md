# Nyra native C toolchain (`nyra cc`)

Foundation for **Native C Compilation** inside the Nyra toolchain — the same direction as [Zig's `zig cc`](https://ziglang.org/documentation/master/#Zig-CC): one driver that picks a consistent LLVM/clang and can grow into bundled sysroots and cross targets.

Nyra already compiles to **LLVM IR** and links with **clang**. `nyra cc` exposes that stack as a first-class C compiler driver for shims, vendored C, and future **Nyra Bindgen**.

## Today (v1 foundation)

| Feature | Status |
|---------|--------|
| Unified clang discovery (`NYRA_LLVM_BIN`, Homebrew LLVM, co-located with `opt`) | ✅ |
| `nyra cc` forwards to clang | ✅ |
| `--for` / `--target` inject cross flags (wasm sysroot, `-target`, …) | ✅ |
| `nyra cc --print-toolchain` | ✅ |
| `CC=nyra cc` for Make/CMake | ✅ |
| Object cache for `link-source` `.c` (incremental `.o`) | ✅ |
| Auto wasm PATH + WASI sysroot on `nyra build --for wasm` | ✅ |
| `nyra toolchain install` — LLVM under `$NYRA_HOME/lib/llvm` | ✅ |
| `nyra toolchain install --download` — official LLVM release | ✅ |
| **Nyra C Bindgen** — `nyra bind c header.h` (libclang → `extern fn`) | ✅ |
| Bundled LLVM inside release `.tar.gz` (no separate install) | 🔜 |

## Usage

```bash
# Show which clang/opt/lld Nyra will use
nyra cc --print-toolchain

# Compile a C shim (same clang as nyra build)
nyra cc -c vendor/mylib_shim.c -o vendor/mylib_shim.o

# Cross-compile C for Wasm (needs wasi-libc + lld on PATH or NYRA_WASI_SYSROOT)
nyra cc --for wasm -c app.c -o app.o

# Use as system CC
export CC="nyra cc"
export CXX="nyra cc"
make
```

## Toolchain layout (bundled install — future)

```
$NYRA_HOME/
  bin/nyra
  lib/llvm/bin/clang, opt, lld, wasm-ld, …
  lib/sysroot/…          # per-target headers + crt (Phase 3)
```

Until bundling ships in release tarballs, install the toolchain locally:

```bash
nyra toolchain install              # symlink Homebrew/system LLVM → ~/.nyra/lib/llvm
nyra toolchain install --download   # fetch official LLVM 18 release
nyra toolchain install --wasi       # + WASI sysroot for wasm builds
nyra toolchain info
source ~/.nyra/env                  # NYRA_LLVM_BIN, NYRA_WASI_SYSROOT
```

Or: `./scripts/install-llvm-toolchain.sh [--download] [--wasi]`

Manual override:

```bash
export NYRA_LLVM_BIN="$(brew --prefix llvm)/bin"   # macOS
export NYRA_WASI_SYSROOT="$(brew --prefix wasi-libc)/share/wasi-sysroot"  # wasm
```

## How this fits Nyra builds

```
.ny sources  →  Nyra compiler  →  .ll (LLVM IR)
                                      ↓
link-source .c  ─────────────────→  nyra cc / clang  →  binary
stdlib/rt/*.c
nyra.mod link -lfoo
```

Package `link-source` files are compiled to cached `.o` files under `target/*/.nyra-cache/c-objs/` during `nyra build` (reused when the `.c` and flags are unchanged). You can also precompile with `nyra cc -c`.

## Roadmap

1. **Phase 1** — `nyra cc`, centralized discovery, docs. ✅
2. **Phase 2** — object cache for `link-source`; auto wasm PATH/sysroot. ✅
3. **Phase 3** — `nyra toolchain install` (+ `--download`), `$NYRA_HOME/lib/llvm` layout, `env` file. ✅
4. **Phase 4** — Nyra C Bindgen (`nyra bind c`) via libclang. ✅ See [c-bindgen.md](c-bindgen.md).

See also [architecture.md](architecture.md) and [bindings.md](bindings.md).
