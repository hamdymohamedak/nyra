#!/usr/bin/env bash
# Smoke-test stdlib SQLite when libsqlite3 is available.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
# shellcheck source=nyra-bin.sh
source "$ROOT/make/lib/nyra-bin.sh"
if [[ -z "${NYRA_BIN:-}" ]]; then nyra_export_cli; fi
NYRA="${NYRA:-$NYRA_BIN}"
FIX="$ROOT/tests/fixtures/sqlite_smoke"

log() { echo "sqlite-smoke: $*" >&2; }

if ! pkg-config --exists sqlite3 2>/dev/null; then
  if [[ ! -f /opt/homebrew/opt/sqlite/lib/libsqlite3.dylib && ! -f /usr/lib/libsqlite3.so && ! -f /usr/local/lib/libsqlite3.dylib ]]; then
    log "skip — libsqlite3 not found"
    exit 0
  fi
fi

log "build + run fixture"
(cd "$FIX" && $NYRA run .)
log "ok"
