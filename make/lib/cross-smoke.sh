#!/usr/bin/env sh
# Cross-compilation smoke tests for Nyra CLI.
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"
. "$ROOT/make/lib/wasm-toolchain.sh"

NYRA="${NYRA:-cargo run --quiet --}"
HELLO="${ROOT}/examples/syntax/hello.ny"

echo "== cross-smoke: wasm32-wasip1 =="
if wasm_toolchain_ready; then
  $NYRA build "$HELLO" --for wasm -o hello.wasm
  WASM_BIN="$(CDPATH= cd -- "$(dirname "$HELLO")" && pwd)/target/wasm32-wasip1/debug/hello.wasm"
  if [ ! -f "$WASM_BIN" ]; then
    echo "missing wasm artifact: $WASM_BIN" >&2
    exit 1
  fi
  echo "wasm artifact: $WASM_BIN"
  if command -v wasmtime >/dev/null 2>&1; then
    wasmtime "$WASM_BIN"
  else
    echo "note: wasmtime not installed; skipping wasm run"
  fi
else
  wasm_toolchain_hint
fi

if [ -n "${NYRA_CROSS_LINUX:-}" ]; then
  echo "== cross-smoke: linux (NYRA_CROSS_LINUX set) =="
  $NYRA build "$HELLO" --release --for linux
  LINUX_BIN="$(CDPATH= cd -- "$(dirname "$HELLO")" && pwd)/target/x86_64-unknown-linux-gnu/release/hello"
  if [ ! -f "$LINUX_BIN" ]; then
    # aarch64 host may emit aarch64-unknown-linux-gnu
    LINUX_BIN="$(CDPATH= cd -- "$(dirname "$HELLO")" && pwd)/target/aarch64-unknown-linux-gnu/release/hello"
  fi
  if [ ! -f "$LINUX_BIN" ]; then
    echo "missing linux cross artifact under target/*-unknown-linux-gnu/release/" >&2
    exit 1
  fi
  echo "linux cross artifact: $LINUX_BIN"
else
  echo "note: set NYRA_CROSS_LINUX=1 with a cross linker to test linux cross-compile"
fi

if [ -n "${NYRA_CROSS_WINDOWS:-}" ]; then
  echo "== cross-smoke: windows (NYRA_CROSS_WINDOWS set) =="
  $NYRA build "${ROOT}/examples/syntax/spawn_channel.ny" --for windows -o spawn_win.exe
  WIN_BIN="$(CDPATH= cd -- "${ROOT}/examples/syntax" && pwd)/target/x86_64-pc-windows-gnu/debug/spawn_win.exe"
  if [ ! -f "$WIN_BIN" ]; then
    WIN_BIN="$(CDPATH= cd -- "${ROOT}/examples/syntax" && pwd)/target/aarch64-pc-windows-gnu/debug/spawn_win.exe"
  fi
  if [ ! -f "$WIN_BIN" ]; then
    echo "missing windows cross artifact under target/*-pc-windows-gnu/debug/" >&2
    exit 1
  fi
  echo "windows cross artifact: $WIN_BIN"
else
  echo "note: set NYRA_CROSS_WINDOWS=1 with mingw-w64 sysroot to test windows cross-compile"
fi

echo "cross-smoke: ok"
