#!/usr/bin/env sh
# Install LLVM/clang into $NYRA_HOME/lib/llvm (symlink from Homebrew/system, or --download).
# Usage:
#   ./scripts/install-llvm-toolchain.sh
#   ./scripts/install-llvm-toolchain.sh --download
#   NYRA_HOME=~/.nyra ./scripts/install-llvm-toolchain.sh --wasi
set -eu

ROOT="$(CDPATH= cd -- "$(dirname "$0")/../.." && pwd)"
NYRA_HOME="${NYRA_HOME:-${HOME}/.nyra}"

DOWNLOAD=0
WASI=0
while [ $# -gt 0 ]; do
  case "$1" in
    --download) DOWNLOAD=1; shift ;;
    --wasi) WASI=1; shift ;;
    -h|--help)
      echo "Usage: $0 [--download] [--wasi]"
      exit 0
      ;;
    *) echo "unknown: $1" >&2; exit 1 ;;
  esac
done

if [ -x "$ROOT/target/debug/nyra" ]; then
  NYRA="$ROOT/target/debug/nyra"
elif [ -x "$NYRA_HOME/bin/nyra" ]; then
  NYRA="$NYRA_HOME/bin/nyra"
elif command -v nyra >/dev/null 2>&1; then
  NYRA=nyra
else
  echo "error: build nyra first (cargo build -p cli) or install nyra" >&2
  exit 1
fi

ARGS=""
[ "$DOWNLOAD" -eq 1 ] && ARGS="$ARGS --download"
[ "$WASI" -eq 1 ] && ARGS="$ARGS --wasi"

export NYRA_HOME
exec "$NYRA" toolchain install $ARGS
