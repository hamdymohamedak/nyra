#!/usr/bin/env sh
# Shared wasm32-wasip1 toolchain setup for cross-smoke and test-all.
# Source this file: . "$ROOT/make/lib/wasm-toolchain.sh"

setup_wasm_toolchain_path() {
  for d in /opt/homebrew/opt/llvm/bin /usr/local/opt/llvm/bin; do
    if [ -x "$d/clang" ]; then
      PATH="$d:$PATH"
    fi
  done
  for d in /opt/homebrew/opt/lld/bin /usr/local/opt/lld/bin; do
    if [ -x "$d/wasm-ld" ]; then
      PATH="$d:$PATH"
    fi
  done
  export PATH
}

detect_wasi_sysroot() {
  if [ -n "${NYRA_WASI_SYSROOT:-}" ]; then
    echo "$NYRA_WASI_SYSROOT"
    return 0
  fi
  if [ -n "${NYRA_SYSROOT:-}" ]; then
    echo "$NYRA_SYSROOT"
    return 0
  fi
  for p in \
    /opt/homebrew/opt/wasi-libc/share/wasi-sysroot \
    /usr/local/opt/wasi-libc/share/wasi-sysroot \
    /usr/share/wasi-sysroot
  do
    if [ -f "$p/lib/wasm32-wasip1/crt1.o" ] || [ -f "$p/lib/wasm32-wasi/crt1.o" ]; then
      echo "$p"
      return 0
    fi
  done
  return 1
}

# Full link probe (compile-only -c misses missing wasm-ld / sysroot).
wasm_toolchain_ready() {
  setup_wasm_toolchain_path
  WASI_SYSROOT="$(detect_wasi_sysroot)" || return 1
  export NYRA_WASI_SYSROOT="$WASI_SYSROOT"
  command -v wasm-ld >/dev/null 2>&1 || return 1
  tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/nyra-wasm-probe.XXXXXX")"
  if clang -target wasm32-wasip1 --sysroot="$WASI_SYSROOT" -nodefaultlibs -lc \
    -x c - -o "$tmpdir/probe.wasm" 2>/dev/null <<<'int main(){return 0;}'
  then
    rm -rf "$tmpdir"
    return 0
  fi
  rm -rf "$tmpdir"
  return 1
}

wasm_toolchain_hint() {
  echo "note: install wasm link deps, e.g. brew install llvm lld wasi-libc (macOS) or apt install clang lld wasi-libc (Debian/Ubuntu)"
}
